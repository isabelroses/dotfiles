{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkOption;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;

  cfg = config.programs.discord;

  settingsFormat = pkgs.formats.json { };
in
{
  options.programs.discord = {
    moonlight = mkOption {
      inherit (settingsFormat) type;
      default = { };
      description = "Settings for Moonlight";
    };
  };

  config = mkMerge [
    (mkIf isDarwin {
      programs.discord.package = null;

      home.file = {
        "Library/Application Support/moonlight-mod/stable.json".source =
          settingsFormat.generate "moonlight-settings.json" cfg.moonlight;
      };
    })

    (mkIf isLinux {
      programs.discord.package = pkgs.discord.override {
        withMoonlight = true;
      };

      xdg.configFile = {
        "moonlight-mod/stable.json".source =
          settingsFormat.generate "moonlight-settings.json" cfg.moonlight;
      };
    })

    {
      programs.discord = {
        settings = {
          SKIP_HOST_UPDATE = true;
          DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING = true;
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
          extensions = {
            # keep-sorted start block=yes
            betterCodeblocks = true;
            betterEmbedsYT = true;
            clearUrls = true;
            cloneExpressions = true;
            copyWebp = true;
            disableSentry = true;
            domOptimizer = true;
            experiments = true;
            favouriteGifSearch = true;
            freeMoji = false;
            freeScreenShare = true;
            greentext = false;
            httpCats = true;
            imageViewer = true;
            inviteToNowhere = true;
            lastFmRpc = false;
            memberCount = true;
            moonbase = true;
            nativeFixes = {
              enabled = pkgs.stdenv.hostPlatform.isLinux;
              config = {
                vaapiIgnoreDriverChecks = true;
                vaapiNvidia = true;
                linuxAutoscroll = true;
                zeroCopy = true;
                ignoreGpuBlocklist = true;
                waylandExplicitSync = true;
              };
            };
            noHideToken = true;
            noReplyChainNag = true;
            noTrack = true;
            onePingPerDM = true;
            openExternally = true;
            ownerCrown = true;
            pronouns = true;
            svgEmbed = true;
            textReplacer = {
              enabled = true;
              config = {
                patterns = {
                  "://tiktok.com/" = "://tnktok.com/";
                  "://vm.tiktok.com/" = "://vm.tnktok.com/";
                  "://www.tiktok.com/" = "://www.tnktok.com/";
                  "://twitter.com/" = "://vxtwitter.com/";
                  "://instagram.com/" = "://vxinstagram.com/";
                  "://www.instagram.com/" = "://vxinstagram.com/";
                  "://reddit.com/" = "://vxreddit.com/";
                  "://www.reddit.com/" = "://vxreddit.com/";
                  "://x.com/" = "://vxtwitter.com/";
                };
              };
            };
            volumeManipulator = true;
            # keep-sorted end
          };

          repositories = [ "https://moonlight-mod.github.io/extensions-dist/repo.json" ];
        };
      };
    }
  ];
}
