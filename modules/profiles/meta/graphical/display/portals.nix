{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkForce;
  inherit (lib.validators) isWayland;

  sys = config.garden.system;
  env = config.garden.environment;
in
{
  config = mkIf (sys.video.enable && pkgs.stdenv.isLinux) {
    xdg.portal = {
      enable = true;
      # xdgOpenUsePortal = true;

      config.common = {
        default = [ "gtk" ];

        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };

      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

      wlr = {
        enable = mkForce (isWayland config && env.desktop != "Hyprland");
        settings = {
          screencast = {
            max_fps = 60;
            chooser_type = "simple";
            chooser_cmd = "${getExe pkgs.slurp} -f %o -or";
          };
        };
      };
    };
  };
}
