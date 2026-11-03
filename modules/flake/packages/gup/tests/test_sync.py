import sqlite3
import tempfile
import threading
import time
import unittest
from contextlib import closing
from pathlib import Path
from unittest.mock import patch

from fake_immich import FakeImmich

from gup import sync
from gup.meta import File, Origin
from gup.state import State
from gup.sync import Sync, hashed, tag_plan

UPLOAD = ("POST", "/assets")
CHECK = "/assets/bulk-upload-check"


def waits_for(condition, seconds=5):
    """Whether condition comes true within seconds."""
    deadline = time.monotonic() + seconds
    while not condition():
        if time.monotonic() > deadline:
            return False
        time.sleep(0.01)
    return True


class TagPlanTests(unittest.TestCase):
    def test_a_tag_shared_across_assets_goes_in_one_request(self):
        author, both = {"Author/x"}, {"Author/x", "Tags/cat"}
        missing = {"a": author, "b": author, "c": both}
        self.assertCountEqual(
            tag_plan(missing),
            [({"Author/x"}, {"a", "b", "c"}), ({"Tags/cat"}, {"c"})],
        )

    def test_assets_lacking_the_same_many_tags_share_one_request(self):
        tags = {f"Tags/{n}" for n in range(5)}
        self.assertEqual(tag_plan({"a": tags, "b": tags}), [(tags, {"a", "b"})])


class SyncTests(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.dir = Path(directory.name)
        self.state = self.enterContext(State.open(self.dir / "state.sqlite3"))

    def recorded(self, key):
        """Whether the state holds key, read on a connection of its own."""
        query = "SELECT 1 FROM uploads WHERE entry = ?"
        with closing(sqlite3.connect(self.dir / "state.sqlite3")) as con:
            return con.execute(query, (key,)).fetchone() is not None

    def download(self, name, data=b"x", post="https://post"):
        (path := self.dir / name).write_bytes(data)
        tags = frozenset({"Tags/cat"})
        return File(path, f"site:{name}", Origin.DOWNLOADED, post, tags)

    def sync(self, client, workers=2, **options):
        return Sync(client, self.state, workers=workers, **options)

    def run_sync(self, immich, files, **options):
        with immich.client() as client:
            run = self.sync(client, **options)
            for file in files:
                run.add(file)
            return run.finish()

    def test_uploads_bring_post_and_tags_and_are_recorded_and_deleted(self):
        immich = FakeImmich()
        file = self.download("a.jpg")
        result = self.run_sync(immich, [file], delete=self.dir)

        [asset_id] = immich.assets
        self.assertEqual(immich.assets[asset_id]["tags"], {"Tags/cat"})
        self.assertEqual(immich.assets[asset_id]["description"], "https://post")
        self.assertEqual(immich.writes, [UPLOAD])
        self.assertNotIn("GET", {method for method, _ in immich.requests})
        self.assertIn(file.key, self.state)
        self.assertFalse(file.path.exists())
        self.assertEqual((result.uploaded, result.removed), (1, 1))

    def test_a_file_is_uploaded_recorded_and_deleted_before_the_next_lands(self):
        immich = FakeImmich()
        file = self.download("a.jpg")
        with immich.client() as client:
            run = self.sync(client, delete=self.dir)
            run.add(file)
            self.assertTrue(waits_for(lambda: self.recorded(file.key)))
            self.assertTrue(waits_for(lambda: not file.path.exists()))
            run.finish()

    def test_abort_records_what_immich_got_and_uploads_nothing_new(self):
        immich = FakeImmich()
        first, second = self.download("a.jpg", b"a"), self.download("b.jpg", b"b")
        release = threading.Event()

        def slow_for_second(path):
            if path == second.path:
                release.wait(5)
            return hashed(path)

        with patch.object(sync, "hashed", slow_for_second), immich.client() as client:
            run = self.sync(client)
            run.add(first)
            self.assertTrue(waits_for(lambda: self.recorded(first.key)))
            run.add(second)
            threading.Timer(0.2, release.set).start()
            run.abort()

        self.assertIn(first.key, self.state)
        self.assertNotIn(second.key, self.state)
        self.assertEqual(immich.writes, [UPLOAD])

    def test_abort_still_fills_in_what_immich_had(self):
        immich = FakeImmich()
        file = self.download("a.jpg")
        asset_id = immich.add(hashed(file.path)[0])
        with immich.client() as client:
            run = self.sync(client)
            run.add(file)
            self.assertTrue(waits_for(lambda: self.recorded(file.key)))
            run.abort()

        self.assertEqual(immich.assets[asset_id]["tags"], {"Tags/cat"})

    def test_a_failing_fill_in_is_not_run_again_by_the_abort_after_it(self):
        immich = FakeImmich()
        file = self.download("a.jpg")
        immich.add(hashed(file.path)[0])
        broken = patch.object(sync, "fill_in", side_effect=RuntimeError("bug"))
        with immich.client() as client, broken as fill_in:
            run = self.sync(client)
            run.add(file)
            with self.assertRaises(RuntimeError):
                run.finish()
            run.abort()

        self.assertEqual(fill_in.call_count, 1)

    def test_a_copy_landing_after_its_upload_counts_as_already_there(self):
        immich = FakeImmich()
        with immich.client() as client:
            run = self.sync(client)
            run.add(self.download("a.jpg"))
            self.assertTrue(waits_for(lambda: self.recorded("site:a.jpg")))
            run.add(self.download("b.jpg"))
            result = run.finish()

        self.assertEqual((result.uploaded, result.already), (1, 1))

    def test_each_content_is_checked_once_before_its_upload(self):
        immich = FakeImmich()
        files = [self.download(f"{n}.jpg", str(n).encode()) for n in range(20)]
        files.append(self.download("copy.jpg", b"0"))
        self.run_sync(immich, files)

        self.assertEqual(immich.requests.count(("POST", CHECK)), 20)
        self.assertEqual(immich.writes.count(UPLOAD), 20)

    def test_copies_handled_at_once_wait_for_one_upload(self):
        immich = FakeImmich()
        files = [self.download(f"{n}.jpg") for n in range(3)]
        with immich.client() as client:
            upload = client.upload

            def slow(*args):
                time.sleep(0.2)
                return upload(*args)

            with patch.object(client, "upload", slow):
                run = self.sync(client, workers=3)
                for file in files:
                    run.add(file)
                result = run.finish()

        self.assertEqual(immich.writes.count(UPLOAD), 1)
        self.assertEqual((result.uploaded, result.already), (1, 2))
        self.assertTrue(all(file.key in self.state for file in files))

    def test_files_given_by_path_start_uploading_before_any_download(self):
        immich = FakeImmich()
        file = self.download("a.jpg")
        with immich.client() as client:
            run = self.sync(client, given=[File(file.path)])
            self.assertTrue(waits_for(lambda: UPLOAD in immich.requests))
            run.finish()

    def test_content_immich_had_gets_the_post_and_tags_it_lacks(self):
        immich = FakeImmich()
        file = self.download("a.jpg")
        asset_id = immich.add(hashed(file.path)[0], tags={"Mine"})
        result = self.run_sync(immich, [file])

        self.assertEqual(immich.assets[asset_id]["tags"], {"Mine", "Tags/cat"})
        self.assertEqual(immich.assets[asset_id]["description"], "https://post")
        self.assertEqual(result.already, 1)
        self.assertIn(file.key, self.state)

    def test_content_immich_had_keeps_its_description_and_isnt_retagged(self):
        immich = FakeImmich()
        file = self.download("a.jpg")
        immich.add(hashed(file.path)[0], tags={"Tags/cat"}, description="mine")
        self.run_sync(immich, [file])

        [asset] = immich.assets.values()
        self.assertEqual(asset["description"], "mine")
        self.assertEqual(immich.writes, [])

    def test_an_asset_two_posts_lead_to_is_described_once(self):
        immich = FakeImmich()
        files = [self.download(f"{n}.jpg", post=f"https://{n}") for n in range(2)]
        asset_id = immich.add(hashed(files[0].path)[0])
        self.run_sync(immich, files)

        self.assertEqual(immich.writes.count(("PUT", "/assets")), 1)
        self.assertIn(
            immich.assets[asset_id]["description"], {"https://0", "https://1"}
        )

    def test_a_file_bringing_no_post_or_tags_costs_no_read(self):
        immich = FakeImmich()
        file = self.download("a.jpg")
        immich.add(hashed(file.path)[0])
        self.run_sync(immich, [], given=[File(file.path)])

        self.assertNotIn("GET", {method for method, _ in immich.requests})

    def test_fill_ins_share_their_requests(self):
        immich = FakeImmich()
        files = [self.download(f"{n}.jpg", str(n).encode()) for n in range(3)]
        for file in files:
            immich.add(hashed(file.path)[0])
        self.run_sync(immich, files)

        self.assertEqual(immich.writes.count(("PUT", "/assets")), 1)
        self.assertEqual(immich.writes.count(("PUT", "/tags")), 1)
        self.assertEqual(immich.writes.count(("PUT", "/tags/assets")), 1)
        for asset in immich.assets.values():
            self.assertEqual(asset["tags"], {"Tags/cat"})
            self.assertEqual(asset["description"], "https://post")

    def test_a_copy_bringing_nothing_new_costs_a_read_and_no_write(self):
        immich = FakeImmich()
        files = [self.download("a.jpg"), self.download("b.jpg", post="https://b")]
        self.run_sync(immich, files)

        self.assertEqual(immich.writes, [UPLOAD])
        self.assertEqual([m for m, _ in immich.requests].count("GET"), 1)

    def test_an_error_on_the_sync_thread_reaches_the_caller(self):
        immich = FakeImmich()
        broken = sqlite3.OperationalError("disk I/O error")
        with (
            patch.object(self.state, "record", side_effect=broken),
            immich.client() as client,
        ):
            run = self.sync(client)
            run.add(self.download("a.jpg"))
            with self.assertRaises(sqlite3.OperationalError):
                run.finish()
            with self.assertRaises(sqlite3.OperationalError):
                run.add(self.download("b.jpg"))

    def test_formats_immich_rejects_are_not_uploaded(self):
        immich = FakeImmich()
        file = self.download("a.psd")
        immich.unsupported.add(hashed(file.path)[0])
        result = self.run_sync(immich, [file], delete=self.dir)

        self.assertEqual(immich.writes, [])
        self.assertEqual(result.failed, 1)
        self.assertNotIn(file.key, self.state)
        self.assertTrue(file.path.exists())

    def test_a_file_only_in_immichs_trash_is_kept_and_not_recorded(self):
        immich = FakeImmich()
        file = self.download("a.jpg")
        sha1 = hashed(file.path)[0]
        immich.add(sha1)
        immich.trashed.add(sha1)
        result = self.run_sync(immich, [file], delete=self.dir)

        self.assertEqual(result.failed, 1)
        self.assertNotIn(file.key, self.state)
        self.assertTrue(file.path.exists())

    def test_a_download_that_changed_since_it_was_hashed_is_kept(self):
        immich = FakeImmich()
        file = self.download("a.jpg")
        with immich.client() as client:
            upload = client.upload

            def changed_meanwhile(path, *args):
                path.write_bytes(b"something else entirely")
                return upload(path, *args)

            with patch.object(client, "upload", changed_meanwhile):
                run = self.sync(client, delete=self.dir)
                run.add(file)
                result = run.finish()

        self.assertTrue(file.path.exists())
        self.assertEqual(result.removed, 0)

    def test_a_file_given_by_hand_is_never_deleted_even_if_downloaded_too(self):
        immich = FakeImmich()
        file = self.download("a.jpg")
        self.run_sync(immich, [file], delete=self.dir, given=[File(file.path)])

        self.assertTrue(file.path.exists())
        self.assertIn(file.key, self.state)

    def test_a_download_that_cant_be_deleted_is_kept_with_a_warning(self):
        immich = FakeImmich()
        file = self.download("a.jpg")
        with (
            patch.object(Path, "unlink", side_effect=PermissionError("denied")),
            self.assertLogs(level="WARNING") as logs,
        ):
            result = self.run_sync(immich, [file], delete=self.dir)

        self.assertIn(file.key, self.state)
        self.assertEqual((result.uploaded, result.removed), (1, 0))
        self.assertIn("denied", logs.output[0])

    def test_abort_starts_no_upload_for_files_waiting_their_turn(self):
        immich = FakeImmich()
        started, release = threading.Event(), threading.Event()
        files = [self.download("a.jpg", b"a"), self.download("b.jpg", b"b")]
        with immich.client() as client:
            upload = client.upload

            def slow(*args):
                started.set()
                release.wait(5)
                return upload(*args)

            with patch.object(client, "upload", slow):
                run = self.sync(client, workers=1)
                run.add(files[0])
                self.assertTrue(waits_for(started.is_set))
                run.add(files[1])
                threading.Timer(0.1, release.set).start()
                run.abort()

        self.assertEqual(immich.writes.count(UPLOAD), 1)
        self.assertIn(files[0].key, self.state)

    def test_a_copy_from_another_post_adds_its_tags_not_its_post(self):
        immich = FakeImmich()
        first = self.download("a.jpg")
        (path := self.dir / "b.jpg").write_bytes(b"x")
        tags = frozenset({"Author/b"})
        copy = File(path, "site:b.jpg", Origin.DOWNLOADED, "https://other", tags)
        with immich.client() as client:
            run = self.sync(client, workers=1)
            run.add(first)
            run.add(copy)
            run.finish()

        [asset] = immich.assets.values()
        self.assertEqual(asset["tags"], {"Tags/cat", "Author/b"})
        self.assertEqual(asset["description"], "https://post")

    def test_a_path_handed_over_again_after_its_deletion_counts_as_already(self):
        immich = FakeImmich()
        file = self.download("a.jpg")
        again = File(file.path, file.key, Origin.ON_DISK, file.post, file.tags)
        with immich.client() as client:
            run = self.sync(client, workers=1, delete=self.dir)
            run.add(file)
            run.add(again)
            result = run.finish()

        counts = result.uploaded, result.already, result.failed, result.removed
        self.assertEqual(counts, (1, 1, 0, 1))

    def test_a_download_outside_the_download_directory_is_never_deleted(self):
        immich = FakeImmich()
        (elsewhere := self.dir / "elsewhere").mkdir()
        file = self.download("a.jpg")
        file = File(file.path.rename(elsewhere / "a.jpg"), file.key, Origin.DOWNLOADED)
        with self.assertLogs(level="WARNING") as logs:
            result = self.run_sync(immich, [file], delete=self.dir / "downloads")

        self.assertTrue(file.path.exists())
        self.assertEqual((result.uploaded, result.removed), (1, 0))
        self.assertIn("outside", logs.output[0])

    def test_files_found_on_disk_are_never_deleted(self):
        immich = FakeImmich()
        file = self.download("a.jpg")
        on_disk = File(file.path, file.key, Origin.ON_DISK)
        self.run_sync(immich, [on_disk], delete=self.dir)

        self.assertTrue(file.path.exists())


if __name__ == "__main__":
    unittest.main()
