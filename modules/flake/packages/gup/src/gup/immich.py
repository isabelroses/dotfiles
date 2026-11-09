"""The few Immich API calls gup makes."""

import re
import time
from datetime import UTC, datetime

import httpx

RETRIES = 2
PING = httpx.Timeout(2)
DROPPED = (httpx.ReadError, httpx.ReadTimeout, httpx.RemoteProtocolError)
CHECK = "/assets/bulk-upload-check"
ID = re.compile(r"[0-9A-Za-z-]+")


class ImmichError(Exception):
    def __init__(self, message, response=None):
        super().__init__(message)
        self.response = response


def checked(value):
    """value if it looks like an Immich id, else ValueError."""
    if not (isinstance(value, str) and ID.fullmatch(value)):
        raise ValueError(f"not an Immich id: {value!r}")
    return value


class Immich(httpx.Client):
    def __init__(self, server, key, transport=None):
        super().__init__(
            base_url=server.rstrip("/") + "/api",
            headers={"x-api-key": key, "Accept": "application/json"},
            timeout=httpx.Timeout(600, connect=30),
            transport=transport or httpx.HTTPTransport(retries=RETRIES),
        )

    def call(self, method, endpoint, read=None, **kwargs):
        """Raises ImmichError for failed requests and unexpected answers."""
        retry = method == "GET" or endpoint == CHECK
        for attempt in range(RETRIES + 1 if retry else 1):
            try:
                r = self.request(method, endpoint, **kwargs)
                r.raise_for_status()
                answer = r.json() if r.content else None
                return read(answer) if read else answer
            except httpx.HTTPError as e:
                if retry and isinstance(e, DROPPED) and attempt < RETRIES:
                    time.sleep(attempt + 1)
                    continue
                raise ImmichError(e, getattr(e, "response", None)) from e
            except (ValueError, KeyError, TypeError, AttributeError) as e:
                raise ImmichError(f"unexpected answer from {endpoint} ({e!r})") from e

    def check(self, sha1s):
        """{sha1: None if Immich lacks it, else (asset id or None, whether trashed)}."""

        def verdict(answer):
            if answer["action"] != "reject":
                return None
            if (asset_id := answer.get("assetId")) is not None:
                asset_id = checked(asset_id)
            return asset_id, bool(answer.get("isTrashed"))

        def verdicts(r):
            found = {a["id"]: verdict(a) for a in r["results"]}
            return {sha1: found[sha1] for sha1 in sha1s}

        assets = [{"id": sha1, "checksum": sha1} for sha1 in sha1s]
        return self.call("POST", CHECK, verdicts, json={"assets": assets})

    def upload(self, path, sha1, sidecar):
        """(asset id, whether Immich already had it), dated by the file's mtime."""
        when = datetime.fromtimestamp(path.stat().st_mtime, UTC).isoformat()
        with path.open("rb") as f:
            fields = dict.fromkeys(("fileCreatedAt", "fileModifiedAt"), when)
            files: dict = {"assetData": (path.name, f, "application/octet-stream")}
            if sidecar:
                files["sidecarData"] = (f"{path.name}.xmp", sidecar)
            return self.call(
                "POST",
                "/assets",
                lambda r: (checked(r["id"]), r["status"] == "duplicate"),
                data=fields,
                files=files,
                headers={"x-immich-checksum": sha1},
            )

    def ping(self):
        """Whether Immich answers quickly, without retrying or raising."""
        try:
            r = self.request("GET", "/server/ping", timeout=PING)
            return r.is_success and r.json().get("res") == "pong"
        except (httpx.HTTPError, ValueError, AttributeError):
            return False

    def account(self):
        return self.call("GET", "/users/me", lambda r: checked(r["id"]))

    def metadata(self, asset_id):
        """The asset's description and tags, or None if it's gone."""

        def read(info):
            description = (info.get("exifInfo") or {}).get("description") or ""
            if not isinstance(description, str):
                raise TypeError(f"description {description!r}")
            return description, {t["value"] for t in info.get("tags") or []}

        try:
            return self.call("GET", f"/assets/{asset_id}", read)
        except ImmichError as e:
            r = e.response
            if r is not None and r.status_code == 400 and "not found" in r.text.lower():
                return None
            raise

    def describe(self, asset_ids, description):
        body = {"ids": sorted(asset_ids), "description": description}
        self.call("PUT", "/assets", json=body)

    def tag_ids(self, tags):
        """{tag: id}, creating the tags Immich lacks."""
        by_name = lambda r: {t["value"]: checked(t["id"]) for t in r}
        return self.call("PUT", "/tags", by_name, json={"tags": sorted(tags)})

    def tag(self, tag_ids, asset_ids):
        """Gives every asset every tag."""
        body = {"tagIds": sorted(tag_ids), "assetIds": sorted(asset_ids)}
        self.call("PUT", "/tags/assets", json=body)
