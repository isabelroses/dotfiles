import unittest
from pathlib import Path
from types import SimpleNamespace

from gup.meta import File, Origin, archive_key, file_from, sidecar, tags_of


def extractor(category, basecategory=""):
    return SimpleNamespace(category=category, basecategory=basecategory)


class ArchiveKeyTests(unittest.TestCase):
    def test_key_comes_from_the_archive_format(self):
        extr = SimpleNamespace(category="twitter", archive_fmt="{tweet_id}_{num}")
        info = {"tweet_id": 9, "num": 1}
        self.assertEqual(archive_key(extr, "u", info), "twitter:9_1")

    def test_url_stands_in_for_a_missing_field(self):
        extr = SimpleNamespace(category="twitter", archive_fmt="{tweet_id}_{num}")
        info = {"tweet_id": 9, "num": None}
        self.assertEqual(
            archive_key(extr, "https://f/1.jpg", info), "twitter:https://f/1.jpg"
        )


class TagTests(unittest.TestCase):
    def test_site_tags_nest_under_tags_beside_source_and_author(self):
        info = {"tags": ["cat", "blue"], "tags_artist": ["artist_name"]}

        self.assertEqual(
            tags_of(extractor("danbooru", "Danbooru"), info),
            {"Source/Danbooru", "Tags/cat", "Tags/blue", "Tags/artist_name"},
        )

    def test_source_tag_is_added_without_metadata_tags(self):
        self.assertEqual(tags_of(extractor("pixiv"), {}), {"Source/Pixiv"})

    def test_social_and_pixiv_tags_are_included_without_hash_prefix(self):
        cases = (
            ("twitter", {"hashtags": ["art", "fanart"]}),
            ("instagram", {"tags": ["#art", "#fanart"]}),
            ("pixiv", {"tags": ["art", "fanart"]}),
        )
        for category, info in cases:
            with self.subTest(category=category):
                self.assertEqual(
                    tags_of(extractor(category), info),
                    {f"Source/{category.title()}", "Tags/art", "Tags/fanart"},
                )

    def test_author_is_tagged_and_slashes_inside_tags_do_not_nest(self):
        info = {"tags": "fate/stay_night saber", "author": "ac/dc"}

        self.assertEqual(
            tags_of(extractor("danbooru", "Danbooru"), info),
            {
                "Source/Danbooru",
                "Author/ac∕dc",
                "Tags/fate∕stay_night",
                "Tags/saber",
            },
        )

    def test_e621_categorized_tags_are_flattened(self):
        info = {"tags": {"artist": ["name"], "general": ["cat"]}}

        self.assertEqual(
            tags_of(extractor("e621", "E621"), info),
            {"Source/E621", "Tags/name", "Tags/cat"},
        )


class OddMetadataTests(unittest.TestCase):
    def test_a_numeric_author_is_tagged(self):
        self.assertIn("Author/123", tags_of(extractor("x"), {"author": 123}))

    def test_grouped_tags_given_as_text_are_split_into_words(self):
        info = {"tags": {"general": "cat dog", "odd": 7}}
        self.assertEqual(
            tags_of(extractor("x"), info), {"Source/X", "Tags/cat", "Tags/dog"}
        )

    def test_a_bare_hash_is_no_tag(self):
        info = {"tags": ["#", "#art"]}
        self.assertEqual(tags_of(extractor("x"), info), {"Source/X", "Tags/art"})

    def test_a_page_url_that_isnt_text_is_ignored(self):
        extr = SimpleNamespace(category="x", basecategory="", root="")
        info = {"webpage_url": ["https://x"]}
        file = file_from(extr, info, Path("a.jpg"), "k", Origin.DOWNLOADED, "fallback")
        self.assertEqual(file.post, "fallback")


class SidecarTests(unittest.TestCase):
    def test_sidecar_carries_the_post_as_description_and_the_tags(self):
        file = File(Path("a.jpg"), post="https://x/?a&b", tags=frozenset({"a&b"}))
        xmp = sidecar(file).decode()

        self.assertIn(
            '<dc:description><rdf:Alt><rdf:li xml:lang="x-default">'
            "https://x/?a&amp;b</rdf:li></rdf:Alt></dc:description>",
            xmp,
        )
        self.assertIn("<tiff:ImageDescription>", xmp)
        self.assertIn("<rdf:li>a&amp;b</rdf:li>", xmp)

    def test_nothing_to_say_means_no_sidecar(self):
        self.assertIsNone(sidecar(File(Path("a.jpg"))))


if __name__ == "__main__":
    unittest.main()
