{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
  mkLink = config.lib.file.mkOutOfStoreSymlink;

  inherit (osConfig.garden.environment) flakePath;
  inherit (config.home) username;

  cfg = config.garden.programs.discord;
in
{
  config = mkIf cfg.enable {
    home = mkMerge [
      (mkIf isLinux {
        packages = [ cfg.package ];
      })

      (mkIf isDarwin {
        file = {
          "Library/Application Support/Vencord/settings/settings.json".source =
            mkLink "${flakePath}/home/${username}/packages/gui/discord/settings.json";
        };
      })
    ];

    # xdg.configFile."discord/settings.json".text = ''
    #   {
    #     "SKIP_HOST_UPDATE": true,
    #     "DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOUR_DOING": true,
    #     "MIN_WIDTH": 940,
    #     "MIN_HEIGHT": 500,
    #     "openasar": {
    #       "setup": true,
    #       "quickstart": true
    #     },
    #     "chromiumSwitches": {},
    #     "IS_MAXIMIZED": true,
    #     "IS_MINIMIZED": false,
    #     "trayBalloonShown": true
    #   }
    # '';
  };
}
