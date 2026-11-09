"""gup: download media with gallery-dl and yt-dlp and upload it to Immich."""

import argparse
import logging
import os
import re
import sys
from contextlib import closing
from dataclasses import dataclass, field
from pathlib import Path
from urllib.parse import urlsplit

from gallery_dl import output as gdl_output

from .fetch import Fetch, download, load_config, setup_gallery_dl
from .immich import Immich, ImmichError
from .meta import File, Origin
from .state import State, StateError, path_for
from .sync import Sync, Upload

URL = re.compile(r"^(ytdl:)?[a-z][a-z0-9+.-]*://", re.IGNORECASE)
USAGE = """\
%(prog)s [OPTIONS] <url|path> [url|path ...]

uploading needs IMMICH_SERVER and IMMICH_API_KEY; IMMICH_SERVER may list
several addresses, split by commas or spaces, tried in order until one answers;
state is kept per Immich account, whatever the server's address"""
log = logging.getLogger("gup")
error = log.error
COLORS = {logging.DEBUG: "2", logging.INFO: "34", logging.WARNING: "33"}


class Formatter(logging.Formatter):
    """[LEVEL] message, the level coloured, other loggers named."""

    def __init__(self, color):
        super().__init__()
        self.color = color

    def format(self, record):
        level = f"[{record.levelname}]"
        if self.color:
            level = f"\033[{COLORS.get(record.levelno, '31')}m{level}\033[0m"
        name = "" if record.name == "gup" else f"[{record.name}]"
        return f"{level}{name} {super().format(record)}"


def parse_args(argv):
    parser = argparse.ArgumentParser(prog="gup", usage=USAGE)
    levels = ("DEBUG", "INFO", "WARNING", "ERROR")
    parser.add_argument(
        "-l", "--log-level", type=str.upper, choices=levels, default="INFO"
    )
    downloads = os.environ.get("XDG_DOWNLOAD_DIR") or Path.home() / "Downloads"
    parser.add_argument("--dir", type=Path, default=Path(downloads))
    parser.add_argument("-n", "--no-upload", dest="upload", action="store_false")
    parser.add_argument("-f", "--refetch", action="store_true")
    parser.add_argument("-d", "--delete", action="store_true")
    parser.add_argument("inputs", nargs="+")
    args = parser.parse_args(argv)
    args.urls = [raw for raw in args.inputs if URL.match(raw)]
    args.paths = [Path(raw) for raw in args.inputs if not URL.match(raw)]
    if missing := [str(p) for p in args.paths if not p.is_file()]:
        parser.error(f"no such file: {', '.join(missing)}")
    if args.dir.exists() and not args.dir.is_dir():
        parser.error(f"--dir {args.dir} isn't a directory")
    if args.paths and not args.upload:
        parser.error("-n only downloads, so files given by path have nothing to do")
    return args


@dataclass(slots=True)
class Run:
    fetches: list[Fetch] = field(default_factory=list)
    upload: Upload = field(default_factory=Upload)

    @property
    def failed(self):
        return any(f.error for f in self.fetches) or self.upload.failed

    def summary(self):
        files = [f for fetch in self.fetches for f in fetch.files]
        failures = [f"{f.url}: {f.error}" for f in self.fetches if f.error]
        up = self.upload
        skipped = sum(f.skipped for f in self.fetches if not f.error)
        counts = [
            (sum(f.origin is Origin.DOWNLOADED for f in files), "file(s) downloaded"),
            (sum(f.origin is Origin.ON_DISK for f in files), "file(s) already on disk"),
            (skipped, "file(s) skipped, gup uploaded them before (-f refetches)"),
            (up.uploaded, "file(s) uploaded to Immich"),
            (up.already, "file(s) already in Immich"),
            (up.failed, "file(s) failed to upload"),
            (up.removed, "downloaded file(s) deleted after upload"),
        ]
        lines = ["", "Summary:"]
        if self.fetches:
            fetched = len(self.fetches) - len(failures)
            lines.append(f"  {fetched} of {len(self.fetches)} URL(s) fetched")
        lines += [f"  {n} {text}" for n, text in counts if n]
        if failures:
            lines += ["Failed:", *(f"  {f}" for f in failures)]
        return "\n".join(lines)


def servers(value):
    """The addresses listed in IMMICH_SERVER, in order."""
    return value.replace(",", " ").split()


def connect(addresses, key, client=Immich):
    """(client, account id) for the first address that answers a ping."""
    for address in addresses:
        immich = client(address, key)
        if immich.ping():
            try:
                return immich, immich.account()
            except BaseException:
                immich.close()
                raise
        immich.close()
        log.warning(f"{address} didn't answer, trying the next server")
    raise ImmichError(f"no Immich server answered ({', '.join(addresses)})")


def upload(args, immich, state):
    setup_gallery_dl(args.dir, None if args.refetch else state.path)
    given = [File(p) for p in args.paths]
    sync = Sync(immich, state, delete=args.dir if args.delete else None, given=given)
    try:
        fetches = []
        for url in args.urls:
            fetches.append(fetch := download(url, sync.add))
            if fetch.error:
                sync.forget(fetch.files)
        return Run(fetches, sync.finish())
    except BaseException:
        sync.abort()
        raise


def main(argv=None):
    args = parse_args(sys.argv[1:] if argv is None else argv)
    level = logging.getLevelNamesMapping()[args.log_level]
    logging.setLoggerClass(gdl_output.Logger)
    handler = logging.StreamHandler()
    color = sys.stderr.isatty() and not os.environ.get("NO_COLOR")
    handler.setFormatter(Formatter(color))
    logging.basicConfig(level=level, handlers=[handler])
    env = {name: os.environ.get(name) for name in ("IMMICH_SERVER", "IMMICH_API_KEY")}
    if args.upload and (missing := [name for name, value in env.items() if not value]):
        error(f"{' and '.join(missing)} must be set to upload")
        sys.exit(1)
    addresses = servers(env["IMMICH_SERVER"] or "")
    for address in addresses if args.upload else ():
        server = urlsplit(address)
        if not (server.scheme in {"http", "https"} and server.netloc):
            error(f"IMMICH_SERVER must list http(s) addresses, not {address!r}")
            sys.exit(1)
    load_config()
    if logfile := gdl_output.setup_logging_handler("logfile", lvl=level):
        logging.getLogger().addHandler(logfile)
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("urllib3").setLevel(logging.ERROR)

    try:
        args.dir.mkdir(parents=True, exist_ok=True)
    except OSError as e:
        error(f"Can't create --dir {args.dir}: {e}")
        sys.exit(1)
    if not args.upload:
        setup_gallery_dl(args.dir)
        run = Run([download(url) for url in args.urls])
    else:
        try:
            immich, account = connect(addresses, env["IMMICH_API_KEY"])
            with closing(immich), State.open(path_for(account)) as state:
                run = upload(args, immich, state)
        except (StateError, ImmichError) as e:
            error(e)
            sys.exit(1)
    if run.failed or level <= logging.INFO:
        print(run.summary())
    if run.failed:
        sys.exit(1)
