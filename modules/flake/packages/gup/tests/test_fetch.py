import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from gallery_dl import config as gdl_config
from gallery_dl import exception as gdl_exception

from gup.fetch import DownloadJob, Fetch, load_config, setup_gallery_dl
from gup.meta import File, Origin
from gup.state import State


class GalleryDlTests(unittest.TestCase):
    URL = "https://yande.re/post/show/1"

    @staticmethod
    def info(n=1):
        return {"id": n, "md5": "m", "filename": "ab"[n - 1], "extension": "jpg"}

    def setUp(self):
        self.addCleanup(gdl_config.clear)
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.dir = Path(directory.name)
        self.state = self.enterContext(State.open(self.dir / "state.sqlite3"))
        self.state.record(File(self.dir / "a.jpg", "yandere:1"), "id")
        setup_gallery_dl(self.dir, self.state.path)
        gdl_config.set(("extractor",), "filename", "{filename}.{extension}")

    def job(self, job_class=DownloadJob, **options):
        self.fetch = Fetch(self.URL, **options)
        job = job_class(self.URL, fetch=self.fetch)
        job.initialize(self.info())
        self.addCleanup(job.archive.close)
        return job

    def test_uploaded_files_skip_through_gallery_dls_archive(self):
        job = self.job()
        job.handle_url("https://files/a.jpg", self.info())

        self.assertEqual((self.fetch.skipped, self.fetch.files), (1, []))

    def test_uploaded_files_count_towards_skip_abort(self):
        gdl_config.set(("extractor",), "skip", "abort:1")
        job = self.job()

        with self.assertRaises(gdl_exception.StopExtraction):
            job.handle_url("https://files/a.jpg", self.info())

    def test_files_on_disk_are_handed_over_and_gallery_dl_never_writes_state(self):
        handed = []
        job = self.job(on_file=handed.append, post="https://example/fallback")
        (self.dir / "b.jpg").write_bytes(b"x")
        job.handle_url("https://files/b.jpg", self.info(2))

        self.assertNotIn("yandere:2", self.state)
        [file] = handed
        self.assertEqual(handed, self.fetch.files)
        self.assertEqual((file.key, file.origin), ("yandere:2", Origin.ON_DISK))
        self.assertEqual(file.post, "https://yande.re/post/show/2")

    def test_an_archive_skip_after_a_file_on_disk_is_not_handed_over(self):
        job = self.job()
        (self.dir / "b.jpg").write_bytes(b"x")
        job.handle_url("https://files/b.jpg", self.info(2))
        job.handle_url("https://files/a.jpg", self.info())

        self.assertEqual((self.fetch.skipped, len(self.fetch.files)), (1, 1))

    def test_a_failing_hand_over_stops_the_run_instead_of_being_logged(self):
        def broken(file):
            raise RuntimeError("state is gone")

        job = self.job(on_file=broken)
        (self.dir / "b.jpg").write_bytes(b"x")
        job.dispatch = lambda _: job.handle_url("https://files/b.jpg", self.info(2))

        with self.assertRaisesRegex(RuntimeError, "state is gone"):
            job.run()

    def test_a_file_gup_cant_describe_fails_its_url_not_the_run(self):
        handed = []
        job = self.job(on_file=handed.append)
        (self.dir / "b.jpg").write_bytes(b"x")
        job.dispatch = lambda _: job.handle_url("https://files/b.jpg", self.info(2))

        with (
            patch("gup.fetch.file_from", side_effect=TypeError("odd tags")),
            self.assertLogs(level="ERROR"),
        ):
            self.assertNotEqual(job.run(), 0)
        self.assertEqual(handed, [])

    def test_the_users_config_wins_over_gups_defaults(self):
        user = self.dir / "config.json"
        user.write_text('{"extractor": {"cookies": "mine.txt"}}')
        with patch.object(gdl_config, "_default_configs", [str(user)]):
            load_config()

        self.assertEqual(gdl_config.get(("extractor",), "cookies"), "mine.txt")
        self.assertIs(gdl_config.get(("extractor", "ytdl"), "enabled"), True)
        [mtime] = gdl_config.get(("extractor",), "postprocessors")
        self.assertEqual(mtime["name"], "mtime")

    def test_gups_cookies_are_used_only_if_they_exist(self):
        cookies = self.dir / "cookies.txt"
        for exists in (False, True):
            with self.subTest(exists=exists):
                gdl_config.clear()
                if exists:
                    cookies.write_text("")
                with (
                    patch("gup.fetch.COOKIES", cookies),
                    patch.object(gdl_config, "_default_configs", []),
                ):
                    load_config()
                found = gdl_config.get(("extractor",), "cookies")
                self.assertEqual(found, str(cookies) if exists else None)

    def test_urls_no_site_takes_go_to_yt_dlp_with_their_query(self):
        script = (
            "from pathlib import Path; from gup.fetch import *;"
            "load_config(); setup_gallery_dl(Path('.'));"
            "url = 'https://video.example/watch?v=1';"
            "fetch = Fetch(url); job = DownloadJob(url, fetch=fetch);"
            "print(job.extractor.category, without_tracking(url, job.extractor))"
        )
        home = {"HOME": str(self.dir), "XDG_CONFIG_HOME": str(self.dir)}
        found = subprocess.run(
            [sys.executable, "-c", script],
            env=os.environ | home,
            capture_output=True,
            text=True,
            check=True,
        )
        category, post = found.stdout.split()
        self.assertEqual(category, "ytdl-generic")
        self.assertEqual(post, "https://video.example/watch?v=1")

    def test_booru_sites_get_grouped_tags(self):
        self.job()
        self.assertIs(gdl_config.get(("extractor", "yandere"), "tags"), True)


if __name__ == "__main__":
    unittest.main()
