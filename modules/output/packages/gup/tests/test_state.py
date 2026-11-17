import sqlite3
import tempfile
import unittest
from contextlib import closing
from pathlib import Path

from gallery_dl import archive as gdl_archive

from gup.meta import File, Origin
from gup.state import TABLE, VERSION, State, StateError


class StateTests(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.dir = Path(directory.name)
        self.path = self.dir / "server.sqlite3"

    def file(self, key="site:1", post="https://post"):
        return File(self.dir / "a.jpg", key, Origin.DOWNLOADED, post)

    def sql(self, script):
        """Runs script on the state file."""
        with closing(sqlite3.connect(self.path)) as con:
            con.executescript(script)

    def test_a_new_state_file_gets_the_current_schema(self):
        with State.open(self.path) as state:
            version = state.con.execute("PRAGMA user_version").fetchone()[0]
        self.assertEqual(version, VERSION)

    def test_state_from_before_versioning_is_refused_untouched(self):
        for user_version in (0, 2):
            with self.subTest(user_version=user_version):
                self.path.unlink(missing_ok=True)
                self.sql(
                    "CREATE TABLE uploads (entry TEXT PRIMARY KEY); "
                    f"PRAGMA user_version = {user_version};"
                )
                with (
                    self.assertRaisesRegex(StateError, "predates"),
                    State.open(self.path),
                ):
                    self.fail("opened a state file from before versioning")
                with closing(sqlite3.connect(self.path)) as con:
                    version = con.execute("PRAGMA user_version").fetchone()[0]
                self.assertEqual(version, user_version)

    def test_state_from_a_newer_gup_is_refused(self):
        self.sql(f"PRAGMA user_version = {VERSION + 1}")
        with self.assertRaisesRegex(StateError, "newer"), State.open(self.path):
            self.fail("opened a state file gup doesn't know")

    def test_uploads_survive_reopen(self):
        with State.open(self.path) as state:
            state.record(self.file(), "id")
        with State.open(self.path) as state:
            self.assertIn("site:1", state)
            self.assertNotIn("site:2", state)

    def test_files_given_by_hand_are_not_recorded(self):
        with State.open(self.path) as state:
            state.record(File(self.dir / "given.jpg"), "id")
            rows = state.con.execute("SELECT count(*) FROM uploads").fetchone()
            self.assertEqual(rows[0], 0)

    def test_gallery_dl_reads_the_table_as_its_archive(self):
        with State.open(self.path) as state:
            state.record(self.file(), "id")
            archive = gdl_archive.connect(str(self.path), "", "{_gup_key}", TABLE)
            try:
                self.assertTrue(archive.check({"_gup_key": "site:1"}))
                self.assertFalse(archive.check({"_gup_key": "other"}))
            finally:
                archive.close()


if __name__ == "__main__":
    unittest.main()
