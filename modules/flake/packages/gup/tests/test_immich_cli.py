import contextlib
from contextlib import closing
import io
import logging
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import httpx
from fake_immich import FakeImmich

from gup.cli import Formatter, connect, main, parse_args, servers
from gup.immich import Immich, ImmichError


class ImmichClientTests(unittest.TestCase):
    def client(self, respond):
        return Immich("https://photos.example", "secret", httpx.MockTransport(respond))

    def test_client_uses_api_prefix_and_auth_header(self):
        seen = []

        def respond(request):
            seen.append(request)
            return httpx.Response(200, json={"ok": True})

        with self.client(respond) as client:
            self.assertEqual(client.call("GET", "/assets/asset-id"), {"ok": True})

        self.assertEqual(seen[0].url.path, "/api/assets/asset-id")
        self.assertEqual(seen[0].headers["x-api-key"], "secret")

    def test_the_duplicate_check_reads_immichs_verdict(self):
        cases = [
            ({"action": "accept"}, None),
            ({"action": "reject", "reason": "duplicate", "assetId": "B"}, ("B", False)),
            ({"action": "reject", "reason": "unsupported-format"}, (None, False)),
            ({"action": "reject", "assetId": "D", "isTrashed": True}, ("D", True)),
        ]
        for answer, verdict in cases:
            with self.subTest(answer=answer):
                results = [{"id": "a", **answer}]
                respond = lambda _, r=results: httpx.Response(200, json={"results": r})
                with self.client(respond) as client:
                    self.assertEqual(client.check(["a"]), {"a": verdict})

    def test_answers_that_arent_immich_ids_are_refused(self):
        for answer in ({"id": None}, {"id": "../../elsewhere"}, {"id": 7}):
            with self.subTest(answer=answer):
                respond = lambda _, answer=answer: httpx.Response(200, json=answer)
                with self.client(respond) as client, self.assertRaises(ImmichError):
                    client.account()

    def test_a_description_that_isnt_text_makes_the_asset_unreadable(self):
        info = {"exifInfo": {"description": {"odd": 1}}, "tags": []}
        respond = lambda _: httpx.Response(200, json=info)
        with self.client(respond) as client, self.assertRaises(ImmichError):
            client.metadata("asset-id")

    def test_only_immichs_400_not_found_means_the_asset_is_gone(self):
        body = {"message": "Not found or no asset.read access"}
        for status, gone in ((400, True), (404, False)):
            with self.subTest(status=status):
                respond = lambda _, s=status: httpx.Response(s, json=body)
                with self.client(respond) as client:
                    if gone:
                        self.assertIsNone(client.metadata("asset-id"))
                    else:
                        self.assertRaises(ImmichError, client.metadata, "asset-id")

    def test_reads_and_checks_are_retried_on_a_dropped_connection_writes_not(self):
        calls = []

        def respond(request):
            calls.append(request.url.path)
            if calls.count(request.url.path) == 1:
                raise httpx.ReadError("dropped")
            accept = {"id": "a", "action": "accept"}
            return httpx.Response(200, json={"results": [accept], "id": "me"})

        with self.client(respond) as client, patch("time.sleep"):
            self.assertEqual(client.check(["a"]), {"a": None})
            self.assertEqual(client.account(), "me")
            with self.assertRaises(ImmichError):
                client.call("PUT", "/assets", json={"ids": []})

        check, me = "/api/assets/bulk-upload-check", "/api/users/me"
        self.assertEqual(calls, [check, check, me, me, "/api/assets"])


class CommandLineTests(unittest.TestCase):
    def test_downloads_are_kept_unless_delete_is_requested(self):
        self.assertFalse(parse_args(["https://example/post"]).delete)

        args = parse_args(["-d", "--dir", "/tmp/gup", "https://example/post"])
        self.assertTrue(args.delete)
        self.assertEqual(args.dir, Path("/tmp/gup"))

    def test_urls_are_told_from_paths_by_their_scheme(self):
        with tempfile.TemporaryDirectory() as directory:
            (path := Path(directory) / "a.jpg").touch()
            args = parse_args(["https://x.com/a", "ytdl:https://y/b", str(path)])

        self.assertEqual(args.urls, ["https://x.com/a", "ytdl:https://y/b"])
        self.assertEqual(args.paths, [path])

    def test_a_missing_path_is_an_error_not_a_url(self):
        with (
            self.assertRaises(SystemExit),
            contextlib.redirect_stderr(io.StringIO()) as stderr,
        ):
            parse_args(["x.com/typo"])
        self.assertIn("no such file: x.com/typo", stderr.getvalue())

    def test_files_given_by_path_need_uploading(self):
        with (
            tempfile.NamedTemporaryFile() as file,
            self.assertRaises(SystemExit),
            contextlib.redirect_stderr(io.StringIO()) as stderr,
        ):
            parse_args(["-n", file.name])
        self.assertIn("-n only downloads", stderr.getvalue())

    def test_uploading_needs_the_server_and_key_from_the_environment(self):
        for env in ({"IMMICH_API_KEY": "k"}, {"IMMICH_SERVER": "http://immich"}):
            with (
                self.subTest(env=env),
                patch.dict("os.environ", env, clear=True),
                patch("logging.basicConfig"),
                self.assertLogs("gup", level="ERROR") as logs,
                self.assertRaises(SystemExit),
            ):
                main(["https://example/post"])
            [missing] = {"IMMICH_SERVER", "IMMICH_API_KEY"} - env.keys()
            self.assertIn(f"{missing} must be set", logs.output[0])

    def test_a_server_without_a_scheme_is_refused_up_front(self):
        env = {"IMMICH_SERVER": "192.168.0.102:3007", "IMMICH_API_KEY": "k"}
        with (
            patch.dict("os.environ", env, clear=True),
            patch("logging.basicConfig"),
            self.assertLogs("gup", level="ERROR") as logs,
            self.assertRaises(SystemExit),
        ):
            main(["https://example/post"])
        self.assertIn("http(s) address", logs.output[0])

    def test_a_list_with_one_address_without_a_scheme_is_refused(self):
        env = {"IMMICH_SERVER": "http://a, 192.168.0.102:3007", "IMMICH_API_KEY": "k"}
        with (
            patch.dict("os.environ", env, clear=True),
            patch("logging.basicConfig"),
            self.assertLogs("gup", level="ERROR") as logs,
            self.assertRaises(SystemExit),
        ):
            main(["https://example/post"])
        self.assertIn("'192.168.0.102:3007'", logs.output[0])

    def test_servers_are_split_by_commas_or_spaces(self):
        self.assertEqual(
            servers(" http://a,http://b  https://c ,\nhttp://d "),
            ["http://a", "http://b", "https://c", "http://d"],
        )

    def test_the_first_server_that_answers_is_used(self):
        fake, tried = FakeImmich(), []

        def client(address, key):
            def respond(request):
                tried.append(address)
                if address == "http://up":
                    return fake.handle(request)
                if address == "http://bad":
                    return httpx.Response(502)
                raise httpx.ConnectError("refused")

            return Immich(address, key, httpx.MockTransport(respond))

        addresses = ["http://down", "http://bad", "http://up", "http://unused"]
        with self.assertLogs("gup", level="WARNING") as logs:
            immich, account = connect(addresses, "key", client)
        with closing(immich):
            self.assertEqual(account, "user-1")
            self.assertEqual(str(immich.base_url), "http://up/api/")
        self.assertNotIn("http://unused", tried)
        self.assertEqual(len(logs.output), 2)

    def test_no_server_answering_is_an_error(self):
        def client(address, key):
            def respond(_):
                raise httpx.ConnectError("refused")

            return Immich(address, key, httpx.MockTransport(respond))

        with (
            self.assertLogs("gup", level="WARNING"),
            self.assertRaisesRegex(ImmichError, "http://a, http://b"),
        ):
            connect(["http://a", "http://b"], "key", client)

    def test_a_dir_that_is_a_file_is_an_error(self):
        with (
            tempfile.NamedTemporaryFile() as file,
            self.assertRaises(SystemExit),
            contextlib.redirect_stderr(io.StringIO()) as stderr,
        ):
            parse_args(["--dir", file.name, "https://example/post"])
        self.assertIn("isn't a directory", stderr.getvalue())

    def test_state_is_named_after_the_keys_user_not_the_server(self):
        with FakeImmich().client() as immich:
            self.assertEqual(immich.account(), "user-1")


class FormatterTests(unittest.TestCase):
    @staticmethod
    def format(name, level, color=False):
        record = logging.LogRecord(name, level, "", 0, "message", None, None)
        return Formatter(color).format(record)

    def test_gups_own_lines_carry_just_the_level(self):
        self.assertEqual(self.format("gup", logging.INFO), "[INFO] message")

    def test_other_loggers_are_named_after_the_level(self):
        self.assertEqual(
            self.format("twitter", logging.ERROR), "[ERROR][twitter] message"
        )

    def test_only_the_level_is_coloured(self):
        self.assertEqual(
            self.format("gup", logging.WARNING, color=True),
            "\033[33m[WARNING]\033[0m message",
        )


if __name__ == "__main__":
    unittest.main()
