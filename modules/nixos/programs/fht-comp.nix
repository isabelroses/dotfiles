{
  lib,
  pkgs,
  self,
  config,
  inputs',
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) anyHome;

  cond = anyHome config (conf: conf.programs.fht-compositor.enable or false);
in
{
  config = mkIf cond {
    xdg.portal = {
      wlr.enable = false;
      configPackages = [ inputs'.fht-compositor.packages.default ];

      config.common = {
        "org.freedesktop.impl.portal.Access" = "gtk";
        "org.freedesktop.impl.portal.Notification" = "gtk";
        "org.freedesktop.impl.portal.ScreenCast" = "fht-compositor";
      };
    };

    services = {
      graphical-desktop.enable = true;
      displayManager.sessionPackages = [ inputs'.fht-compositor.packages.default ];
    };

    garden.packages = {
      fht-compositor = inputs'.fht-compositor.packages.default;
      fht-share-picker = inputs'.fht-share-picker.packages.default;
      inherit (pkgs) xdg-utils;
    };
  };
}
