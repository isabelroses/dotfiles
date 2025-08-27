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
        "https://aprl.cat/rss.xml"

        # cool people
        # keep-sorted start
        "https://aly.codes/index.xml"
        "https://antfu.me/feed.xml"
        "https://cafkafk.dev/index.xml"
        "https://fasterthanli.me/index.xml"
        "https://jade.fyi/rss.xml"
        "https://mitchellh.com/feed.xml"
        "https://mrcjkb.dev/atom.xml"
        # keep-sorted end
        # cool orgs
        # keep-sorted start
        "https://100r.co/links/rss.xml"
        "https://charm.sh/blog/rss.xml"
        # keep-sorted end

        # keep-sorted start
        "https://basil.cafe/feeds/posts.xml"
        "https://blog.gitbutler.com/rss/"
        "https://blog.ihatereality.space/atom.xml"
        "https://blog.orhun.dev/rss.xml"
        "https://boxesandarrows.com/feed/"
        "https://browsercompany.substack.com/feed"
        "https://dataswamp.org/~solene/rss-html.xml"
        "https://dotfyle.com/this-week-in-neovim/rss.xml"
        "https://feeds.feedburner.com/tom-preston-werner"
        "https://github.blog/open-source/feed/"
        "https://hypr.land/rss.xml"
        "https://maia.crimew.gay/feed.xml"
        "https://medium.com/feed/better-programming"
        "https://namishh.me/rss.xml"
        "https://nixpkgs.news/rss.xml"
        "https://overreacted.io/rss.xml"
        "https://sapphic.moe/rss.xml"
        "https://xeiaso.net/blog.rss"
        # keep-sorted end
      ];
    };
  };
}
