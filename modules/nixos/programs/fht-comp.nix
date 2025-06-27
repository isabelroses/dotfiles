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
    services.displayManager.sessionPackages = [ inputs'.fht-compositor.packages.default ];

    xdg.portal = {
      configPackages = [ inputs'.fht-compositor.packages.default ];
      wlr.enable = false;
    };

    garden.packages = {
      fht-share-picker = inputs'.fht-share-picker.packages.default;
      inherit (pkgs) xdg-utils;
    };
  };
}
