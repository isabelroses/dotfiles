{
  lib,
  pkgs,
  self,
  config,
  inputs',
  modulesPath,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
  inherit (self.lib) anyHome;

  cond = anyHome config (conf: conf.programs.fht-compositor.enable or false);
in
{
  config = mkIf cond (mkMerge [
    {
      xdg.portal = {
        wlr.enable = false;
        configPackages = [ inputs'.fht-compositor.packages.default ];

        config.common = {
          "org.freedesktop.impl.portal.Access" = "gtk";
          "org.freedesktop.impl.portal.Notification" = "gtk";
          "org.freedesktop.impl.portal.ScreenCast" = "fht-compositor";
        };
      };

      services.displayManager.sessionPackages = [ inputs'.fht-compositor.packages.default ];

      garden.packages = {
        fht-compositor = inputs'.fht-compositor.packages.default;
        fht-share-picker = inputs'.fht-share-picker.packages.default;
        inherit (pkgs) xdg-utils;
      };
    }

    (import "${modulesPath}/programs/wayland/wayland-session.nix" {
      inherit lib pkgs;
      enableXWayland = false; # we dont have xwayland support
      enableWlrPortal = false; # fht-compositor ships its own portal.
    })
  ]);
}
