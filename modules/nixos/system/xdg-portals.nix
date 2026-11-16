{
  lib,
  pkgs,
  config,
  extpkgs,
  ...
}:
let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkDefault;
in
{
  xdg.portal = {
    enable = mkDefault config.garden.profiles.graphical.enable;

    xdgOpenUsePortal = true;

    extraPortals = [ extpkgs.xdg-desktop-portal-gtk4 ];

    config.common = {
      default = [ "gtk4" ];

      "org.freedesktop.impl.portal.Secret" = [ "oo7-portal" ];
    };

    wlr = {
      enable = mkDefault config.garden.profiles.graphical.enable;
      settings = {
        screencast = {
          max_fps = 60;
          chooser_type = "simple";
          chooser_cmd = "${getExe pkgs.slurp} -f %o -or";
        };
      };
    };
  };
}
