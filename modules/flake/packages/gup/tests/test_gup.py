"""Focused regression tests for gup's persistent upload state."""

import importlib.machinery
import importlib.util
import logging
import sys
import tempfile
import unittest
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor
from dataclasses import replace
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parents[1] / "gup"
loader = importlib.machinery.SourceFileLoader("gup", str(SCRIPT))
spec = importlib.util.spec_from_loader(loader.name, loader)
gup = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = gup
loader.exec_module(gup)


class ArchivePathTests(unittest.TestCase):
    def test_trailing_slash_does_not_create_a_second_archive(self):
        self.assertEqual(
            gup.archive_path("https://photos.example/"),
            gup.archive_path("https://photos.example"),
        )


class UploadedStateTests(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.dir = Path(directory.name)
        self.archive = self.dir / "server"

    def download(self, name="post.jpg", key="key"):
        (path := self.dir / name).write_bytes(b"x")
        return gup.File(path, key, "downloaded", description="https://example/post")

    def test_pending_upload_survives_reopen_and_can_be_settled(self):
        file = replace(self.download(), tags=frozenset({"Source/Danbooru", "cat"}))
        with gup.Uploaded.open(self.archive) as archive:
            asset = archive.remember(file, "asset-id")

        with gup.Uploaded.open(self.archive) as archive:
            self.assertIn("key", archive)
            self.assertEqual(archive.pending, [asset])
            archive.settle([asset], [])

        with gup.Uploaded.open(self.archive) as archive:
            self.assertIn("key", archive)
            self.assertEqual(archive.pending, [])

    def test_keyless_upload_round_trips_and_is_never_marked_settled(self):
        file = gup.File(self.dir / "given.jpg")
        with gup.Uploaded.open(self.archive) as archive:
            asset = archive.remember(file, "asset-id")

        with gup.Uploaded.open(self.archive) as archive:
            self.assertEqual(archive.pending, [asset])
            self.assertEqual(asset.key, "")
            archive.settle([asset], [])

        with gup.Uploaded.open(self.archive) as archive:
            self.assertEqual(archive.pending, [])
            self.assertNotIn("asset:asset-id", archive)

    def test_settled_copy_is_deleted_on_a_later_run_without_delete(self):
        file = self.download()
        with gup.Uploaded.open(self.archive) as archive:
            archive.remember(file, "id", delete=True)

        with gup.Uploaded.open(self.archive) as archive:
            [asset] = archive.pending
            with patch.object(gup, "reconcile", return_value=([asset], [])):
                result = gup.upload_to_immich(None, [], archive)

        self.assertFalse(file.path.exists())
        self.assertEqual((result.removed, result.removing), (1, 0))

    def test_copy_that_changed_since_upload_is_kept(self):
        file = self.download()
        with gup.Uploaded.open(self.archive) as archive:
            asset = archive.remember(file, "id", delete=True)
            file.path.write_bytes(b"another file under the same name")
            self.assertEqual(archive.settle([asset], []), 0)

        self.assertTrue(file.path.exists())

    def test_copy_given_by_hand_this_run_is_kept(self):
        file = self.download()
        with gup.Uploaded.open(self.archive) as archive:
            asset = archive.remember(file, "id", delete=True)
            self.assertEqual(archive.settle([asset], [], {file.path.resolve()}), 0)

        self.assertTrue(file.path.exists())

    def test_only_downloads_get_a_copy_to_delete(self):
        with gup.Uploaded.open(self.archive) as archive:
            for origin in ("given", "on disk"):
                file = replace(self.download(), origin=origin)
                self.assertIsNone(archive.remember(file, "id", delete=True).copy)

    def test_copy_path_survives_a_relative_download_dir(self):
        file = self.download()
        relative = Path(gup.os.path.relpath(file.path))
        with gup.Uploaded.open(self.archive) as archive:
            asset = archive.remember(replace(file, path=relative), "id", delete=True)

        self.assertTrue(asset.copy.path.is_absolute())


class ArchiveKeyTests(unittest.TestCase):
    def test_key_comes_from_the_archive_format(self):
        extr = SimpleNamespace(category="twitter", archive_fmt="{tweet_id}_{num}")
        info = {"tweet_id": 9, "num": 1}
        self.assertEqual(gup.archive_key(extr, "u", info), "twitter:9_1")

    def test_url_stands_in_for_a_missing_field(self):
        extr = SimpleNamespace(category="twitter", archive_fmt="{tweet_id}_{num}")
        info = {"tweet_id": 9, "num": None}
        self.assertEqual(
            gup.archive_key(extr, "https://f/1.jpg", info), "twitter:https://f/1.jpg"
        )


class GalleryDlArchiveTests(unittest.TestCase):
    URL = "https://yande.re/post/show/1"

    @staticmethod
    def info():
        return {"id": 1, "md5": "m", "filename": "a", "extension": "jpg"}

    def setUp(self):
        self.addCleanup(gup.gdl_config.clear)
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        gup.setup_gallery_dl(Path(directory.name))

    def job(self, uploaded):
        job = gup.CollectJob(self.URL, archive=uploaded)
        job.initialize(self.info())
        return job

    def test_uploaded_files_skip_through_gallery_dls_archive(self):
        job = self.job({"yandere:1"})
        job.handle_url("https://files/a.jpg", self.info())

        self.assertEqual((job.skipped, job.files, job.found), (["yandere:1"], [], True))

    def test_uploaded_files_count_towards_skip_abort(self):
        gup.gdl_config.set(("extractor",), "skip", "abort:1")
        job = self.job({"yandere:1"})

        with self.assertRaises(gup.gdl_exception.StopExtraction):
            job.handle_url("https://files/a.jpg", self.info())

    def test_booru_sites_get_grouped_tags(self):
        self.job(set())
        self.assertIs(gup.gdl_config.get(("extractor", "yandere"), "tags"), True)

    def test_own_archive_still_answers(self):
        inner = SimpleNamespace(check=lambda kwdict: True)
        job = SimpleNamespace(
            extractor=SimpleNamespace(category="x", archive_fmt="{id}"),
            url="u",
            key="",
            uploaded=set(),
            skipped=[],
        )
        self.assertTrue(gup.SkipUploaded(job, inner).check({"id": 2}))
        self.assertEqual((job.key, job.skipped), ("x:2", []))


class PushTests(unittest.TestCase):
    class Client:
        def __init__(self, known=()):
            self.have, self.uploads = dict.fromkeys(known, "old"), []

        def known(self, checksums):
            return {c: self.have[c] for c in checksums if c in self.have}

        def upload(self, path, sha1, posted=None, sidecar=None):
            self.uploads.append(path.name)
            return "new", False

    def files(self, directory, contents):
        paths = []
        for name, data in contents.items():
            (path := Path(directory) / name).write_bytes(data)
            paths.append(gup.File(path, name, "downloaded"))
        return paths

    def test_same_content_is_sent_once_and_its_copies_wait_for_immich(self):
        with tempfile.TemporaryDirectory() as directory:
            files = self.files(directory, {"a.jpg": b"x", "b.jpg": b"x"})
            client = self.Client()
            with gup.Uploaded.open(Path(directory) / "server") as archive:
                with patch.object(gup, "reconcile", return_value=([], [])) as rec:
                    result = gup.upload_to_immich(client, files, archive)

                self.assertEqual(client.uploads, ["a.jpg"])
                self.assertEqual(rec.call_args.args[1], [])
                self.assertEqual(len(archive.pending), 2)
            self.assertEqual((result.uploaded, result.already), (1, 1))

    def test_formats_immich_rejects_are_not_uploaded(self):
        with tempfile.TemporaryDirectory() as directory:
            [file] = self.files(directory, {"a.psd": b"x"})
            client = self.Client()
            client.have[gup.sha1_of(file.path)] = None
            with ThreadPoolExecutor(2) as pool:
                results = list(gup.push(client, [file], pool))

            self.assertEqual(results, [(file, None, "")])
            self.assertEqual(client.uploads, [])

    def test_assets_deleted_from_immich_are_forgotten_on_the_same_run(self):
        with tempfile.TemporaryDirectory() as directory:
            [file] = self.files(directory, {"a.jpg": b"x"})
            client = self.Client(known=[gup.sha1_of(file.path)])
            with gup.Uploaded.open(Path(directory) / "server") as archive:
                with patch.object(
                    gup, "reconcile", side_effect=lambda _, a, __: ([], a)
                ):
                    result = gup.upload_to_immich(client, [file], archive)

                self.assertNotIn("a.jpg", archive)
            self.assertEqual((result.already, result.gone), (1, 1))


class ImmichClientTests(unittest.TestCase):
    def test_client_uses_api_prefix_and_auth_header(self):
        seen = []

        def respond(request):
            seen.append(request)
            return gup.httpx.Response(200, json={"ok": True})

        transport = gup.httpx.MockTransport(respond)
        with (
            patch.object(gup.httpx, "HTTPTransport", return_value=transport),
            gup.Immich("https://photos.example", "secret") as client,
        ):
            self.assertEqual(client.call("GET", "/assets/asset-id"), {"ok": True})

        self.assertEqual(seen[0].url.path, "/api/assets/asset-id")
        self.assertEqual(seen[0].headers["x-api-key"], "secret")

    def test_bulk_upload_check_maps_rejects_and_skips_accepts(self):
        results = [
            {"id": "a", "action": "accept"},
            {"id": "b", "action": "reject", "reason": "duplicate", "assetId": "B"},
            {"id": "c", "action": "reject", "reason": "unsupported-format"},
        ]
        transport = gup.httpx.MockTransport(
            lambda _: gup.httpx.Response(200, json={"results": results})
        )
        with (
            patch.object(gup.httpx, "HTTPTransport", return_value=transport),
            gup.Immich("https://photos.example", "secret") as client,
        ):
            self.assertEqual(client.known(["a", "b", "c"]), {"b": "B", "c": None})


class CommandLineTests(unittest.TestCase):
    def test_downloads_are_kept_unless_delete_is_requested(self):
        with patch.object(gup.sys, "argv", ["gup", "https://example/post"]):
            self.assertFalse(gup.parse_args().delete)

        with patch.object(
            gup.sys, "argv", ["gup", "-d", "--dir", "/tmp/gup", "https://example/post"]
        ):
            args = gup.parse_args()
        self.assertTrue(args.delete)
        self.assertEqual(args.dir, Path("/tmp/gup"))


class MetadataTagTests(unittest.TestCase):
    def test_booru_and_source_tags_are_added(self):
        extractor = SimpleNamespace(category="danbooru", basecategory="Danbooru")
        info = {"tags": ["cat", "blue"], "tags_artist": ["artist_name"]}

        self.assertEqual(
            gup.tags_of(extractor, info),
            {"Source/Danbooru", "cat", "blue", "artist_name"},
        )

    def test_source_tag_is_added_without_metadata_tags(self):
        extractor = SimpleNamespace(category="pixiv", basecategory="")

        self.assertEqual(gup.tags_of(extractor, {}), {"Source/Pixiv"})

    def test_social_and_pixiv_tags_are_included_without_hash_prefix(self):
        cases = (
            ("twitter", {"hashtags": ["art", "fanart"]}),
            ("instagram", {"tags": ["#art", "#fanart"]}),
            ("pixiv", {"tags": ["art", "fanart"]}),
        )
        for category, info in cases:
            with self.subTest(category=category):
                extractor = SimpleNamespace(category=category, basecategory="")
                self.assertEqual(
                    gup.tags_of(extractor, info),
                    {f"Source/{category.title()}", "art", "fanart"},
                )

    def test_author_is_tagged_and_slashes_do_not_nest(self):
        extractor = SimpleNamespace(category="danbooru", basecategory="Danbooru")
        info = {"tags": "fate/stay_night saber", "author": "ac/dc"}

        self.assertEqual(
            gup.tags_of(extractor, info),
            {"Source/Danbooru", "Author/ac\u2215dc", "fate\u2215stay_night", "saber"},
        )

    def test_sidecar_carries_the_files_description_and_tags(self):
        file = gup.File(
            Path("a.jpg"), description="https://x/?a&b", tags=frozenset({"Author/x"})
        )
        xmp = gup.sidecar(file).decode()

        self.assertIn("https://x/?a&amp;b", xmp)
        self.assertIn("<rdf:li>Author/x</rdf:li>", xmp)

    def test_e621_categorized_tags_are_flattened(self):
        extractor = SimpleNamespace(category="e621", basecategory="E621")

        self.assertEqual(
            gup.tags_of(extractor, {"tags": {"artist": ["name"], "general": ["cat"]}}),
            {"Source/E621", "name", "cat"},
        )

    def test_reconcile_reads_duplicate_asset_ids_once_and_unions_tags(self):
        class Client:
            def __init__(self):
                self.reads = []
                self.tagged = []

            def metadata(self, asset_id):
                self.reads.append(asset_id)
                return "existing description", set()

            def describe(self, asset_ids, description):
                self.fail("existing descriptions must be preserved")

            def tag_ids(self, tags):
                return {tag: tag for tag in tags}

            def tag(self, tag_ids, ids):
                self.tagged.append((frozenset(tag_ids), ids))

        client = Client()
        assets = [
            gup.Asset("same", "first", tags=frozenset({"one"})),
            gup.Asset("same", "second", tags=frozenset({"two"})),
        ]
        with ThreadPoolExecutor(2) as pool:
            settled, gone = gup.reconcile(client, assets, pool)

        self.assertEqual(client.reads, ["same"])
        self.assertEqual(set(settled), set(assets))
        self.assertEqual(gone, [])
        self.assertEqual(client.tagged, [(frozenset({"one", "two"}), {"same"})])

    def test_files_of_one_post_are_described_in_one_request(self):
        described = []

        class Client:
            def metadata(self, asset_id):
                return "", set()

            def describe(self, asset_ids, description):
                described.append((set(asset_ids), description))

            def tag_ids(self, tags):
                return {tag: tag for tag in tags}

            def tag(self, tag_ids, ids):
                pass

        assets = [
            gup.Asset("1", description="https://x.com/i/status/9"),
            gup.Asset("2", description="https://x.com/i/status/9"),
            gup.Asset("3", description="https://x.com/i/status/8"),
        ]
        with ThreadPoolExecutor(2) as pool:
            settled, _ = gup.reconcile(Client(), assets, pool)

        self.assertCountEqual(
            described,
            [
                ({"1", "2"}, "https://x.com/i/status/9"),
                ({"3"}, "https://x.com/i/status/8"),
            ],
        )
        self.assertEqual(settled, assets)

    def test_tag_plan_takes_the_fewer_requests(self):
        authors = {"a": {"Author/x"}, "b": {"Author/x"}, "c": {"Author/x", "cat"}}
        self.assertEqual(
            sorted(gup.tag_plan(authors), key=str),
            [({"Author/x"}, {"a", "b", "c"}), ({"cat"}, {"c"})],
        )

        posts = {"a": {"cat", "blue", "x"}, "b": {"dog", "red", "x"}}
        self.assertEqual(len(gup.tag_plan(posts)), 2)

    def test_tag_plan_gives_each_asset_exactly_its_tags(self):
        by_tag = {"a": {"1", "2"}, "b": {"2"}, "c": {"1", "2"}, "d": set()}
        by_set = {"a": {"1", "2"}, "b": {"3", "4"}, "c": {"5", "6"}}
        for missing in (by_tag, by_set):
            given = defaultdict(set)
            for tags, ids in gup.tag_plan(missing):
                for asset_id in ids:
                    given[asset_id] |= tags
            self.assertEqual(given, {k: v for k, v in missing.items() if v})


class ColorLoggingTests(unittest.TestCase):
    def test_formatter_can_emit_color_or_plain_levels(self):
        record = logging.LogRecord("gup", logging.INFO, "", 0, "ready", (), None)

        self.assertIn("\033[34m[INFO]", gup.ColorFormatter(True).format(record))
        self.assertEqual(gup.ColorFormatter(False).format(record), "[INFO] ready")


if __name__ == "__main__":
    unittest.main()
