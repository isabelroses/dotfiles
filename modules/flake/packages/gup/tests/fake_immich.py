"""An Immich server in memory, behind httpx.MockTransport."""

import html
import json
import re
import uuid

import httpx

from gup.immich import Immich

DESCRIPTION = re.compile(
    rb'<dc:description><rdf:Alt><rdf:li xml:lang="x-default">(.*?)<'
)
TAGS = re.compile(rb"<digiKam:TagsList><rdf:Seq>(.*?)</rdf:Seq>")
ITEM = re.compile(rb"<rdf:li>(.*?)</rdf:li>")


class FakeImmich:
    """Records requests, and reads sidecars on upload."""

    def __init__(self):
        self.assets, self.by_sum, self.tag_ids, self.requests = {}, {}, {}, []
        self.unsupported, self.trashed = set(), set()

    account = "user-1"

    def client(self):
        return Immich("https://immich.test", "key", httpx.MockTransport(self.handle))

    @property
    def writes(self):
        return [r for r in self.requests if r[0] != "GET" and "bulk" not in r[1]]

    def add(self, checksum="sum", tags=(), description=""):
        asset_id = str(uuid.uuid4())
        self.assets[asset_id] = {"tags": set(tags), "description": description}
        self.by_sum[checksum] = asset_id
        return asset_id

    def handle(self, request):
        request.read()
        method, path = request.method, request.url.path.removeprefix("/api")
        self.requests.append((method, path))
        match method, path:
            case "POST", "/assets/bulk-upload-check":
                assets = json.loads(request.content)["assets"]
                results = [self.check(a) for a in assets]
                return httpx.Response(200, json={"results": results})
            case "POST", "/assets":
                return self.upload(request)
            case "GET", "/users/me":
                return httpx.Response(200, json={"id": self.account})
            case "GET", _ if asset := self.assets.get(path.rpartition("/")[2]):
                tags = [{"id": t, "value": t} for t in sorted(asset["tags"])]
                info = {"exifInfo": {"description": asset["description"]}}
                return httpx.Response(200, json={**info, "tags": tags})
            case "PUT", "/assets":
                body = json.loads(request.content)
                for asset_id in body["ids"]:
                    self.assets[asset_id]["description"] = body["description"]
                return httpx.Response(204)
            case "PUT", "/tags":
                tags = json.loads(request.content)["tags"]
                ids = {t: self.tag_ids.setdefault(t, str(uuid.uuid4())) for t in tags}
                answer = [{"id": ids[t], "value": t} for t in tags]
                return httpx.Response(200, json=answer)
            case "PUT", "/tags/assets":
                body = json.loads(request.content)
                names = {v: k for k, v in self.tag_ids.items()}
                for asset_id in body["assetIds"]:
                    self.assets[asset_id]["tags"] |= {names[t] for t in body["tagIds"]}
                return httpx.Response(200, json=[])
        if method == "GET" and path.startswith("/assets/"):
            message = "Not found or no asset.read access"
            return httpx.Response(400, json={"message": message})
        return httpx.Response(404, json={"message": f"no route {method} {path}"})

    def check(self, asset):
        checksum = asset["checksum"]
        if checksum in self.unsupported:
            return {"id": checksum, "action": "reject", "reason": "unsupported-format"}
        if asset_id := self.by_sum.get(checksum):
            return {
                "id": checksum,
                "action": "reject",
                "reason": "duplicate",
                "assetId": asset_id,
                "isTrashed": checksum in self.trashed,
            }
        return {"id": checksum, "action": "accept"}

    def upload(self, request):
        checksum = request.headers["x-immich-checksum"]
        if asset_id := self.by_sum.get(checksum):
            return httpx.Response(200, json={"id": asset_id, "status": "duplicate"})
        description, tags = "", set()
        if found := DESCRIPTION.search(request.content):
            description = html.unescape(found[1].decode())
        if found := TAGS.search(request.content):
            tags = {html.unescape(t.decode()) for t in ITEM.findall(found[1])}
        asset_id = self.add(checksum, tags, description)
        return httpx.Response(201, json={"id": asset_id, "status": "created"})
