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
        "https://nixpkgs.news/rss.xml"
        "https://maia.crimew.gay/feed.xml"
        "https://100r.co/links/rss.xml"
        "https://aly.codes/index.xml"
        "https://aprl.cat/rss.xml"
        "https://basil.cafe/feeds/posts.xml"
        "https://blog.gitbutler.com/rss/"
        "https://boxesandarrows.com/feed/"
        "https://browsercompany.substack.com/feed"
        "https://cafkafk.dev/index.xml"
        "https://dotfyle.com/this-week-in-neovim/rss.xml"
        "https://feeds.feedburner.com/tom-preston-werner"
        "https://github.blog/open-source/feed/"
        "https://hypr.land/rss.xml"
        "https://jade.fyi/rss.xml"
        "https://medium.com/feed/better-programming"
        "https://mrcjkb.dev/atom.xml"
        "https://namishh.me/rss.xml"
        "https://overreacted.io/rss.xml"
        "https://sapphic.moe/rss.xml"
        "https://xeiaso.net/blog.rss"
        "https://blog.ihatereality.space/atom.xml"
      ];
    };
  };
}
