{ config, ... }:
{
  programs.izrss = {
    inherit (config.garden.profiles.workstation) enable;

    settings = {
      reader.size = "full";

      urls = [
        "https://isabelroses.com/feed.xml"
        "https://robinroses.xyz/feed.xml"
        "https://uncenter.dev/feed.xml"
        "https://charm.sh/blog/rss.xml"
        "https://antfu.me/feed.xml"
        "https://fasterthanli.me/index.xml"
        "https://blog.orhun.dev/rss.xml"
        "https://mitchellh.com/feed.xml"
        "https://dataswamp.org/~solene/rss-html.xml"
        "https://ayats.org/index.xml"
        "https://nixpkgs.news/rss.xml"
        "https://maia.crimew.gay/feed.xml"
        "https://forum.aux.computer/tag/security-advisory.rss"
      ];
    };
  };
}
