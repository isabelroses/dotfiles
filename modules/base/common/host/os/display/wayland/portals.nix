{
  config,
  lib,
  pkgs,
  ...
}: let
  sys = config.modules.system;
  env = config.modules.usrEnv;
  inherit (lib) mkForce mkIf;
in {
  config = mkIf sys.video.enable {
    xdg.portal = {
      enable = true;
      # xdgOpenUsePortal = true;
      config.common.default = "*";

      configPackages = with pkgs; [
        xdg-desktop-portal-gtk
      ];

      wlr = {
        enable = mkForce (env.isWayland && env.desktop != "Hyprland");
        settings = {
          screencast = {
            max_fps = 60;
            chooser_type = "simple";
            chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
          };
        };
      };
    };
  };
}
