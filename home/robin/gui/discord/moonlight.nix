{ config }:
let
  evcfg = config.evergarden;
in
{
  extensions = {
    moonbase = true;
    disableSentry = true;
    noTrack = true;
    noHideToken = true;
    alwaysFocus = {
      enabled = true;
    };
    betterCodeblocks = {
      enabled = true;
    };
    betterEmbedsYT = {
      enabled = true;
    };
    callIdling = {
      enabled = true;
    };
    callTimer = {
      enabled = true;
    };
    clearUrls = {
      enabled = true;
    };
    cloneExpressions = {
      enabled = true;
    };
    moonlight-css = {
      enabled = true;
      config = {
        cssPath = "/home/robin/.config/moonlight-mod/themes/";
        recurseDirectory = false;
        fileSelector = ".*\\.theme\\.css";
        paths = [
          "/home/robin/.config/moonlight-mod/themes/"
          "@dark https://everviolet.github.io/discord/themes/evergarden-${evcfg.variant}-${evcfg.accent}.theme.css"
          "@light https://everviolet.github.io/discord/themes/evergarden-summer-aqua.theme.css"
        ];
        themeAttributes = true;
      };
    };
    decor = {
      enabled = true;
    };
    dmDates = {
      enabled = true;
    };
    dmFavorites = {
      enabled = true;
    };
    domOptimizer = {
      enabled = true;
    };
    freeScreenShare = {
      enabled = true;
    };
    freeMoji = {
      enabled = true;
    };
    imgTitle = {
      enabled = true;
    };
    inAppNotifications = {
      enabled = true;
    };
    markdown = {
      enabled = true;
    };
    memberCount = {
      enabled = true;
    };
    mentionAvatars = {
      enabled = true;
    };
    nativeFixes = {
      enabled = true;
      config = {
        vulkan = true;
        disableRendererBackgrounding = false;
        linuxUpdater = true;
      };
    };
    neatSettingsContext = {
      enabled = true;
    };
    nicknameTools = {
      enabled = true;
      config = {
        usernameEqualsDisplayname = "Show Username";
        reply = "Show Both";
      };
    };
    noHelp = {
      enabled = true;
    };
    noJoinMessageWave = {
      enabled = true;
    };
    noNotificationSoundExceptDms = {
      enabled = true;
    };
    platformStyles = {
      enabled = true;
      config = {
        style = "osx";
      };
    };
    pronouns = {
      enabled = true;
    };
    remind-me = {
      enabled = true;
    };
    textReplacer = {
      enabled = true;
      config = {
        patterns = {
          "://x.com/" = "://fixupx.com/";
          "://reddit.com/" = "://rxddit.com/";
          "://vm.tiktok.com/" = "://vm.vxtiktok.com/";
          "://bsky.app/" = "://fxbsky.app/";
        };
      };
    };
    staffTags = {
      enabled = true;
      config = {
        style = "icon";
      };
    };
    spotifySpoof = {
      enabled = true;
    };
    showVoiceMemberCount = {
      enabled = true;
    };
    showReplySelf = {
      enabled = true;
    };
    showMediaOptions = {
      enabled = true;
    };
    showAllRoles = {
      enabled = true;
    };
    sendTimestamps = {
      enabled = true;
    };
    experiments = {
      enabled = true;
      config = {
        devtools = true;
        staffSettings = true;
      };
    };
    unminifyReactErrors = {
      enabled = true;
    };
    ownerCrown = {
      enabled = true;
    };
    platformIcons = {
      enabled = true;
      config = {
        self = false;
        memberList = false;
      };
    };
    uwuifier = true;
    translateText = true;
  };
  repositories = [
    "https://moonlight-mod.github.io/extensions-dist/repo.json"
  ];
}
