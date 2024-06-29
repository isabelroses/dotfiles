{
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  programs.newsboat = lib.mkIf osConfig.modules.programs.tui.enable {
    enable = true;
    autoReload = true;
    maxItems = 0;

    urls = [
      {
        title = "Uncenter";
        tags = [
          "webdev"
          "friends"
        ];
        url = "https://uncenter.dev/feed.xml";
      }
      {
        title = "Me";
        tags = [ "me" ];
        url = "https://isabelroses.com/rss.xml";
      }
      {
        title = "antfu";
        tags = [ "webdev" ];
        url = "https://antfu.me/feed.xml";
      }
      {
        title = "fasterthenli";
        tags = [
          "webdev"
          "rust"
          "nix"
        ];
        url = "https://fasterthanli.me/index.xml";
      }
      {
        title = "orhun";
        tags = [
          "rust"
          "linux"
        ];
        url = "https://blog.orhun.dev/rss.xml";
      }
      {
        title = "mitchellh";
        tags = [ "terminal" ];
        url = "https://mitchellh.com/feed.xml";
      }
      {
        title = "solene";
        tags = [
          "linux"
          "bsd"
          "nix"
        ];
        url = "https://dataswamp.org/~solene/rss.xml";
      }
      {
        title = "viperml";
        tags = [ "nix" ];
        url = "https://ayats.org/index.xml";
      }
      {
        title = "Nixpkgs News";
        tags = [ "nix" ];
        url = "https://nixpkgs.news/rss.xml";
      }
      {
        title = "maia crimew";
        tags = [ "hacking" ];
        url = "https://maia.crimew.gay/feed.xml";
      }
    ];

    extraConfig = builtins.readFile (
      pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/newsboat/main/themes/dark";
        sha256 = "09x50g74mld8zv8r6a873j52zx3w86qv3mc7g4fhzr85911cz799";
      }
    );
  };
}
