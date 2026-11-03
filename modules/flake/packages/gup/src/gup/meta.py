"""What gup says about each file: its archive key, post, date, and tags."""

from dataclasses import dataclass
from enum import StrEnum
from pathlib import Path
from xml.sax.saxutils import escape

from gallery_dl import formatter as gdl_formatter

POST_URLS = {
    "Danbooru": "{root}/posts/{id}",
    "E621": "{root}/posts/{id}",
    "gelbooru": "{root}/index.php?page=post&s=view&id={id}",
    "gelbooru_v02": "{root}/index.php?page=post&s=view&id={id}",
    "moebooru": "{root}/post/show/{id}",
    "pixiv": "https://www.pixiv.net/artworks/{id}",
    "twitter": "https://x.com/i/status/{tweet_id}",
}
SLASH = "∕"


class Origin(StrEnum):
    GIVEN = "given"
    DOWNLOADED = "downloaded"
    ON_DISK = "on disk"


@dataclass(frozen=True, slots=True)
class File:
    path: Path
    key: str = ""
    origin: Origin = Origin.GIVEN
    post: str = ""
    tags: frozenset[str] = frozenset()


def archive_key(extr, url, info):
    """A stable id from the archive format, else from the file's url."""
    if extr.archive_fmt:
        present = {k: v for k, v in info.items() if v is not None}
        key = gdl_formatter.parse(extr.archive_fmt, "\0").format_map(present)
        if key and "\0" not in key:
            return f"{extr.category}:{key}"
    return f"{extr.category}:{url}"


def author_of(info):
    author = info.get("author") or info.get("user") or info.get("pinner")
    if isinstance(author, dict):
        keys = ("name", "handle", "uniqueId", "username")
        author = next(filter(None, map(author.get, keys)), None)
    fallbacks = ("username", "blog_name", "channel", "uploader")
    author = author or next(filter(None, map(info.get, fallbacks)), "")
    return str(author) if isinstance(author, str | int) else ""


def words(value):
    """The tags in a metadata value, skipping anything that isn't text."""
    if isinstance(value, str):
        return value.split()
    if isinstance(value, dict):
        return [word for group in value.values() for word in words(group)]
    if isinstance(value, list | tuple):
        return [item for item in value if isinstance(item, str)]
    return []


def tag(*parts):
    return "/".join(part.replace("/", SLASH) for part in parts)


def tags_of(extr, info):
    base = extr.basecategory
    source = base if base in {"Danbooru", "E621"} else extr.category
    tags = {tag("Source", source.title())}
    if author := author_of(info):
        tags.add(tag("Author", author))
    for key, value in info.items():
        if key not in {"tags", "hashtags"} and not key.startswith("tags_"):
            continue
        found = (word.lstrip("#").strip() for word in words(value))
        tags.update(tag("Tags", word) for word in found if word)
    return frozenset(tags)


def post_url(extr, info):
    template = POST_URLS.get(extr.category) or POST_URLS.get(extr.basecategory)
    try:
        return template.format_map({"root": extr.root, **info}) if template else ""
    except KeyError:
        return ""


def file_from(extr, info, path, key, origin, post=""):
    if not isinstance(url := info.get("webpage_url"), str):
        url = ""
    post = url or post_url(extr, info) or post
    return File(path, key, origin, post, tags_of(extr, info))


def sidecar(file):
    """XMP carrying the post and tags, for Immich to read on upload."""
    fields = []
    if post := escape(file.post):
        alt = f'<rdf:Alt><rdf:li xml:lang="x-default">{post}</rdf:li></rdf:Alt>'
        fields.append(f"<dc:description>{alt}</dc:description>")
        fields.append(f"<tiff:ImageDescription>{alt}</tiff:ImageDescription>")
    if file.tags:
        seq = "".join(f"<rdf:li>{escape(t)}</rdf:li>" for t in sorted(file.tags))
        fields.append(f"<digiKam:TagsList><rdf:Seq>{seq}</rdf:Seq></digiKam:TagsList>")
    if not fields:
        return None
    body = "\n".join(fields)
    return f"""\
<x:xmpmeta xmlns:x="adobe:ns:meta/">
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description rdf:about=""
 xmlns:dc="http://purl.org/dc/elements/1.1/"
 xmlns:tiff="http://ns.adobe.com/tiff/1.0/"
 xmlns:digiKam="http://www.digikam.org/ns/1.0/">
{body}
</rdf:Description>
</rdf:RDF>
</x:xmpmeta>
""".encode()
