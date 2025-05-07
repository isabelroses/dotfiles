{
  extensions = {
    moonbase = true;
    disableSentry = true;
    noTrack = true;
    noHideToken = true;
    betterCodeblocks = true;
    betterEmbedsYT = true;
    clearUrls = true;
    cloneExpressions = true;
    domOptimizer = true;
    freeScreenShare = true;
    greentext = true;
    lastFmRpc = false;
    memberCount = true;
    onePingPerDM = true;
    pronouns = true;
    textReplacer = {
      enabled = true;
      config = {
        patterns = {
          "://x.com/" = "://fxtwitter.com/";
          "://twitter.com/" = "://fxtwitter.com/";
          "://www.reddit.com/" = "://rxddit.com/";
          "://reddit.com/" = "://rxddit.com/";
          "://www.instagram.com/" = "://ddinstagram.com/";
          "://instagram.com/" = "://ddinstagram.com/";
          "://www.tiktok.com/" = "://tfxktok.com/";
          "://vm.tiktok.com/" = "://vm.vxtiktok.com/";
          "://tiktok.com/" = "://tfxktok.com/";
          "://bsky.app/" = "://fxbsky.app/";
        };
      };
    };
  };
  repositories = [
    "https://moonlight-mod.github.io/extensions-dist/repo.json"
  ];
}
