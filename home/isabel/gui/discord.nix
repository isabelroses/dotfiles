# this is a custom module provided by this flake. it is not in home-manager
{
  programs.discord = {
    settings = {
      SKIP_HOST_UPDATE = true;
      DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOUR_DOING = true;
      MIN_WIDTH = 940;
      MIN_HEIGHT = 500;
      openasar = {
        setup = true;
        quickstart = true;
      };
      chromiumSwitches = { };
      IS_MAXIMIZED = true;
      IS_MINIMIZED = false;
      trayBalloonShown = true;
    };

    moonlight = {
      enable = true;
      settings = {
        extensions = {
          betterCodeblocks = true;
          betterEmbedsYT = true;
          clearUrls = true;
          cloneExpressions = true;
          copyWebp = true;
          disableSentry = true;
          domOptimizer = true;
          experiments = true;
          freeMoji = false;
          freeScreenShare = true;
          greentext = false;
          httpCats = true;
          inviteToNowhere = true;
          lastFmRpc = false;
          memberCount = true;
          moonbase = true;
          noHideToken = true;
          noReplyChainNag = true;
          noTrack = true;
          onePingPerDM = true;
          pronouns = true;
          textReplacer = {
            config = {
              patterns = {
                "://bsky.app/" = "://fxbsky.app/";
                "://instagram.com/" = "://ddinstagram.com/";
                "://reddit.com/" = "://rxddit.com/";
                "://tiktok.com/" = "://tfxktok.com/";
                "://twitter.com/" = "://fxtwitter.com/";
                "://vm.tiktok.com/" = "://vm.vxtiktok.com/";
                "://www.instagram.com/" = "://ddinstagram.com/";
                "://www.reddit.com/" = "://rxddit.com/";
                "://www.tiktok.com/" = "://tfxktok.com/";
                "://x.com/" = "://fxtwitter.com/";
              };
            };
            enabled = true;
          };
        };
        repositories = [ "https://moonlight-mod.github.io/extensions-dist/repo.json" ];
      };
    };
  };
}
