{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.garden.profiles.graphical.enable {
    services.xserver = {
      enable = false;
      desktopManager.xterm.enable = false;

      excludePackages = [ pkgs.xterm ];
    };
  };
}
