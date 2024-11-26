{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  cfg = osConfig.garden.programs.discord;
in
{
  config = mkIf cfg.enable {
    home.packages = mkIf pkgs.stdenv.hostPlatform.isLinux [
      cfg.package
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
