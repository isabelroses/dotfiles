{ glanceLib, ... }:
let
  inherit (glanceLib) mkPage mkFeeds;
in
mkPage "Reads" [
  {
    type = "rss";
    title = "People I Follow";
    style = "horizontal-cards";
    feeds = mkFeeds [
      "https://uncenter.dev/feed.xml"
      "https://antfu.me/feed.xml"
      "https://fasterthanli.me/index.xml"
      "https://blog.orhun.dev/rss.xml"
      "https://mitchellh.com/feed.xml"
      "https://dataswamp.org/~solene/rss-html.xml"
      "https://maia.crimew.gay/feed.xml"
    ];
  }

  {
    type = "rss";
    title = "Tech News";
    style = "horizontal-cards";
    feeds = mkFeeds [
      "https://clan.lol/feed.xml"
      "https://charm.sh/blog/rss.xml"
    ];
  }

  {
    type = "rss";
    title = "Git Commits";
    style = "vertical-list";
    feeds = mkFeeds [
      "https://github.com/moonlight-mod/extensions/commits.atom"
    ];
  }
]
