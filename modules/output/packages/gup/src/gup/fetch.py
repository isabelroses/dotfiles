"""Downloads with gallery-dl, handing each file over as it lands."""

import logging
import re
from collections import defaultdict
from collections.abc import Callable
from dataclasses import dataclass, field
from pathlib import Path

from gallery_dl import config as gdl_config
from gallery_dl import job as gdl_job
from gallery_dl.extractor.booru import BooruExtractor

from .meta import File, Origin, archive_key, file_from
from .state import STATE, TABLE

KEY = "_gup_key"
COOKIES = STATE / "gup/cookies.txt"
DEFAULTS = {
    ("extractor",): {
        "postprocessors": [
            {"name": "ugoira", "mode": "mkvmerge"},
            {"name": "mtime", "value": "{date|timestamp}"},
        ],
    },
    ("extractor", "ytdl"): {"enabled": True},
}

log = logging.getLogger("gup").info


class HandOverError(BaseException):
    """Escapes gallery-dl, which logs and ignores a hook's Exceptions."""


def apply(options):
    """Sets options one by one, so gallery-dl's config merge can't alter them."""
    for path, values in options.items():
        for option, value in values.items():
            gdl_config.set(path, option, value)


def load_config():
    """gup's defaults, then the user's config; before gallery-dl imports ytdl."""
    apply(DEFAULTS)
    if COOKIES.exists():
        gdl_config.set(("extractor",), "cookies", str(COOKIES))
    gdl_config.load()


def setup_gallery_dl(out_dir, archive=None):
    """Sets what gup needs of gallery-dl, reading gup's state as its archive."""
    extractor = {"base-directory": str(out_dir), "directory": [""]}
    if archive is not None:
        extractor |= {
            "archive": str(archive),
            "archive-table": TABLE,
            "archive-prefix": "",
            "archive-format": f"{{{KEY}}}",
            "archive-event": [],
        }
    apply({("extractor",): extractor, ("output",): {"mode": "null"}})


@dataclass(slots=True)
class Fetch:
    url: str
    post: str = ""
    on_file: Callable[[File], None] | None = None
    files: list[File] = field(default_factory=list)
    skipped: int = 0
    error: str = ""

    def hand_over(self, extr, pathfmt, origin):
        info, path = pathfmt.kwdict, Path(pathfmt.path)
        file = file_from(extr, info, path, info[KEY], origin, self.post)
        self.files.append(file)
        if self.on_file:
            try:
                self.on_file(file)
            except Exception as e:  # noqa: BLE001
                raise HandOverError(e) from None


class DownloadJob(gdl_job.DownloadJob):
    """Hands each file to its fetch, which child jobs share."""

    def __init__(self, url, parent=None, fetch=None):
        super().__init__(url, parent)
        self.fetch = fetch or parent.fetch
        self.top = parent is None
        self.overwrites = self.extractor.config("skip", True) is False
        if isinstance(self.extractor, BooruExtractor):
            gdl_config.set(("extractor", self.extractor.category), "tags", True)

    def run(self):
        try:
            return super().run()
        except HandOverError as e:
            if not self.top:
                raise
            raise e.args[0] from None

    def initialize(self, kwdict=None):
        super().initialize(kwdict)
        self.hooks = self.hooks or defaultdict(list)
        self.register_hooks({"after": self.downloaded, "skip": self.skipped})

    def handle_url(self, url, kwdict):
        kwdict[KEY] = archive_key(self.extractor, url, kwdict)
        super().handle_url(url, kwdict)

    def downloaded(self, pathfmt):
        origin = Origin.ON_DISK if self.overwrites else Origin.DOWNLOADED
        self.fetch.hand_over(self.extractor, pathfmt, origin)
        log(f"Downloaded {pathfmt.filename}")

    def skipped(self, pathfmt):
        """Archive first: its skips leave the last file's path behind."""
        if self.archive is not None and self.archive.check(pathfmt.kwdict):
            self.fetch.skipped += 1
            log(f"Skip {pathfmt.filename}")
        elif pathfmt.path and Path(pathfmt.path).exists():
            self.fetch.hand_over(self.extractor, pathfmt, Origin.ON_DISK)
            log(f"Already here: {pathfmt.filename}")


def without_tracking(url, extr):
    """Drops the query unless the extractor needs it."""
    bare = re.split(r"[?#]", url, maxsplit=1)[0]
    match = type(extr).pattern.match(bare)
    return bare if match and match.groups() == extr.groups else url


def download(raw, on_file=None):
    fetch = Fetch(raw, on_file=on_file)
    job = DownloadJob(raw, fetch=fetch)
    fetch.post = without_tracking(raw, job.extractor)
    log(f"Fetch {fetch.post}")
    if status := job.run():
        fetch.error = f"gallery-dl exited with status {status}"
    elif not (fetch.files or fetch.skipped):
        fetch.error = "nothing to download"
    return fetch
