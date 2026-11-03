import hashlib
import logging
import threading
from collections import defaultdict
from concurrent.futures import CancelledError, Future, ThreadPoolExecutor
from dataclasses import dataclass, replace
from functools import partial

from .immich import ImmichError
from .meta import Origin, sidecar

WORKERS, UPLOADS, READS, WRITES = 8, 4, 16, 8

logger = logging.getLogger("gup")
log, warn = logger.info, logger.warning


def stat_of(path):
    stat = path.stat()
    return stat.st_size, stat.st_mtime_ns


def hashed(path):
    """The file's sha1, and its size and mtime from just before reading it."""
    stat = stat_of(path)
    with path.open("rb") as f:
        return hashlib.file_digest(f, "sha1").hexdigest(), stat


@dataclass(slots=True)
class Upload:
    uploaded: int = 0
    already: int = 0
    failed: int = 0
    removed: int = 0


def attempt(failed, fn, *args):
    """A fill-in request, which may fail without failing the run."""
    try:
        return fn(*args)
    except ImmichError as e:
        warn(f"{failed}: {e}")


def tag_plan(missing):
    """The fewest (tags, asset ids) requests giving each asset its tags."""
    by_tag, by_set = defaultdict(set), defaultdict(set)
    for asset_id, tags in missing.items():
        by_set[frozenset(tags)].add(asset_id)
        for tag in tags:
            by_tag[tag].add(asset_id)
    if len(by_tag) <= len(by_set):
        return [({tag}, ids) for tag, ids in by_tag.items()]
    return list(by_set.items())


def fill_in(immich, unfilled):
    """Adds missing posts and tags to assets, never replacing a description."""
    describe, missing, tag_ids = defaultdict(set), {}, {}

    def read(asset_id):
        return attempt(f"Reading {asset_id} failed", immich.metadata, asset_id)

    with ThreadPoolExecutor(READS) as pool:
        haves = list(pool.map(read, unfilled))
    for (asset_id, files), have in zip(unfilled.items(), haves):
        if have is None:
            continue
        description, tags = have
        post = next((f.post for f in files if f.post), "")
        if post and not description.strip():
            describe[post].add(asset_id)
        if lacking := set().union(*(f.tags for f in files)) - tags:
            missing[asset_id] = lacking
    if names := set().union(*missing.values()):
        tag_ids = attempt("Creating tags failed", immich.tag_ids, names) or {}
    calls = [
        partial(attempt, f"Describing {post} failed", immich.describe, ids, post)
        for post, ids in describe.items()
    ]
    for tags, ids in tag_plan(missing):
        if tags <= tag_ids.keys():
            found = {tag_ids[t] for t in tags}
            calls.append(partial(attempt, "Tagging failed", immich.tag, found, ids))
    with ThreadPoolExecutor(WRITES) as pool:
        list(pool.map(lambda call: call(), calls))


class Sync:
    """Uploads files as they come, each content once."""

    def __init__(self, immich, state, *, workers=WORKERS, delete=None, given=()):
        """delete is the download directory to delete uploads from, or None."""
        self.immich, self.state = immich, state
        self.delete = delete and delete.resolve()
        self.workers = ThreadPoolExecutor(workers)
        self.keep = {f.path.resolve() for f in given}
        self.uploading = threading.Semaphore(UPLOADS)
        self.stopping, self.error = False, None
        self.lock = threading.RLock()
        self.result = Upload()
        self.uploads = {}
        self.unfilled = defaultdict(list)
        self.removed = {}
        try:
            for file in given:
                self.add(file)
        except BaseException:
            self.abort()
            raise

    def add(self, file):
        """Hands a file over. Raises what failed a worker, if anything did."""
        if self.error:
            raise self.error
        if self.keep and file.path.resolve() in self.keep:
            file = replace(file, origin=Origin.GIVEN)
        self.workers.submit(self.guarded, self.handle, file)

    def finish(self):
        """Waits for everything to be uploaded, recorded, and filled in."""
        self.wind_down()
        if self.error:
            raise self.error
        return self.result

    def abort(self):
        """Starts no new upload, but records and fills in what Immich got."""
        self.stopping = True
        self.wind_down()

    def wind_down(self):
        """Waits for every file, then fills in once, even if abort follows."""
        self.workers.shutdown()
        unfilled, self.unfilled = self.unfilled, defaultdict(list)
        if unfilled:
            fill_in(self.immich, unfilled)

    def guarded(self, fn, *args):
        """Keeps what failed for finish to raise."""
        try:
            fn(*args)
        except BaseException as e:  # noqa: BLE001
            self.error = self.error or e

    def handle(self, file):
        if self.stopping:
            return
        try:
            sha1, stat = hashed(file.path)
        except OSError as e:
            with self.lock:
                asset_id = self.removed.get(str(file.path.resolve()))
            if asset_id and isinstance(e, FileNotFoundError):
                self.settle(file, None, asset_id, had=False, fresh=False)
            else:
                self.fail(f"Can't read {file.path.name}: {e}")
            return
        if self.stopping:
            return
        with self.lock:
            upload = self.uploads.get(sha1)
            if first := upload is None:
                upload = self.uploads[sha1] = Future()
        if first:
            self.send(sha1, file, upload)
        try:
            asset_id, had = upload.result() if isinstance(upload, Future) else upload
        except CancelledError:
            return
        except (ImmichError, OSError) as e:
            self.fail(f"Upload failed {file.path.name}: {e}")
            return
        self.settle(file, stat, asset_id, had, fresh=first and not had)

    def send(self, sha1, file, upload):
        """Checks, then uploads unless Immich has it; copies get the outcome."""
        try:
            try:
                verdict = self.immich.check(sha1)
            except ImmichError as e:
                warn(f"Duplicate check failed; uploading anyway: {e}")
                verdict = None
            if verdict:
                asset_id, trashed = verdict
                if trashed:
                    restore = f"restore {asset_id} to keep it"
                    raise ImmichError(f"it's in Immich's trash, {restore}")
                if not asset_id:
                    raise ImmichError("Immich doesn't support this format")
                outcome = asset_id, True
            elif self.stopping:
                upload.cancel()
                return
            else:
                with self.uploading:
                    outcome = self.immich.upload(file.path, sha1, sidecar(file))
        except BaseException as e:
            upload.set_exception(e)
            if not isinstance(e, (ImmichError, OSError)):
                raise
            return
        upload.set_result(outcome)
        with self.lock:
            self.uploads[sha1] = outcome

    def settle(self, file, stat, asset_id, had, fresh):
        """Records the file and queues its fill-in; copies keep the description."""
        with self.lock:
            self.state.record(file, asset_id)
            if not fresh:
                fill = file if had else replace(file, post="")
                if fill.post or fill.tags:
                    self.unfilled[asset_id].append(fill)
            self.result.uploaded += fresh
            self.result.already += not fresh
        log(f"{'Uploaded' if fresh else 'Already'}: {file.path.name}")
        if self.delete and file.origin is Origin.DOWNLOADED:
            self.remove(file.path, stat, asset_id)

    def remove(self, path, stat, asset_id):
        if not (resolved := path.resolve()).is_relative_to(self.delete):
            warn(f"Kept {path}, it's outside {self.delete}")
            return
        try:
            if stat_of(path) != stat:
                log(f"Kept {path.name}, it changed since it was uploaded")
                return
            path.unlink()
        except FileNotFoundError:
            return
        except OSError as e:
            warn(f"Can't delete {path.name}, keeping it: {e}")
            return
        with self.lock:
            self.result.removed += 1
            self.removed[str(resolved)] = asset_id

    def fail(self, message):
        warn(message)
        with self.lock:
            self.result.failed += 1
