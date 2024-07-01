{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf osConfig.modules.programs.gui.discord.enable {
    home.packages = mkIf pkgs.stdenv.isLinux [
      (pkgs.discord.override {
        # withOpenASAR = true;
        # withVencord = true;
      })
    ];

    xdg.configFile."discord/settings.json".text = ''
      {
        "SKIP_HOST_UPDATE": true,
        "DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOUR_DOING": true,
        "MIN_WIDTH": 940,
        "MIN_HEIGHT": 500,
        "openasar": {
          "setup": true,
          "quickstart": true
        },
        "chromiumSwitches": {},
        "IS_MAXIMIZED": true,
        "IS_MINIMIZED": false,
        "trayBalloonShown": true
      }
    '';
  };
}
