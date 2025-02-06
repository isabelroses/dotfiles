{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkForce;
  inherit (self.lib.validators) isWayland;

  sys = config.garden.system;
  inherit (config.garden) meta;
in
{
  config = mkIf (sys.video.enable && meta.isWM) {
    xdg.portal = {
      enable = true;
      # xdgOpenUsePortal = true;

      config.common = {
        default = [ "gtk" ];

        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };

      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

      wlr = {
        enable = mkForce (isWayland config && meta.hyprland);
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
