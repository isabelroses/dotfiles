"""What gup uploaded, one SQLite file per Immich account."""

import os
import sqlite3
from contextlib import closing, contextmanager
from datetime import UTC, datetime
from pathlib import Path

STATE = Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local/state")
UPLOADED = STATE / "gup/uploaded"
TABLE = "uploads"
VERSION = 3
SCHEMA = f"""
CREATE TABLE IF NOT EXISTS {TABLE} (
    entry TEXT PRIMARY KEY,
    asset_id TEXT NOT NULL,
    post TEXT NOT NULL,
    uploaded_at TEXT NOT NULL
) WITHOUT ROWID;
"""


class StateError(Exception):
    pass


def path_for(account):
    return UPLOADED / f"{account}.sqlite3"


@contextmanager
def transaction(con):
    con.execute("BEGIN IMMEDIATE")
    try:
        yield con
        con.execute("COMMIT")
    except BaseException:
        if con.in_transaction:
            con.execute("ROLLBACK")
        raise


def check_schema(con, path):
    """Creates the schema in a new file, refusing any other version."""
    version = con.execute("PRAGMA user_version").fetchone()[0]
    if version > VERSION:
        raise StateError(f"{path} is from a newer gup (schema {version})")
    if version < VERSION:
        if con.execute(f"PRAGMA table_info({TABLE})").fetchone():
            raise StateError(f"{path} predates schema {VERSION}; move it aside")
        with transaction(con):
            con.executescript(f"{SCHEMA} PRAGMA user_version = {VERSION};")


class State:
    """The state file, used by one thread at a time."""

    def __init__(self, con, path):
        self.con, self.path = con, path

    @classmethod
    @contextmanager
    def open(cls, path):
        path.parent.mkdir(parents=True, exist_ok=True)
        connect = sqlite3.connect(
            path, timeout=60, autocommit=True, check_same_thread=False
        )
        with closing(connect) as con:
            con.execute("PRAGMA journal_mode=WAL")
            con.execute("PRAGMA synchronous=NORMAL")
            check_schema(con, path)
            yield cls(con, path)

    def __contains__(self, key):
        query = f"SELECT 1 FROM {TABLE} WHERE entry = ?"
        return self.con.execute(query, (key,)).fetchone() is not None

    def record(self, file, asset_id):
        """Records file as asset_id, unless it has no key."""
        if file.key:
            now = datetime.now(UTC).isoformat(timespec="seconds")
            row = file.key, asset_id, file.post, now
            with transaction(self.con) as con:
                con.execute(f"INSERT OR REPLACE INTO {TABLE} VALUES (?, ?, ?, ?)", row)

    def forget(self, keys):
        with transaction(self.con) as con:
            con.executemany(f"DELETE FROM {TABLE} WHERE entry = ?", [(k,) for k in keys])
