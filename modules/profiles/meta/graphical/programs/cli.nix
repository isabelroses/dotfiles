{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.lists) optional;
  inherit (lib.validators) isWayland;
in
{
  programs = {
    # its actually useful but i don't use it much anymore
    # type "fuck" to fix the last command that made you go "fuck"
    # thefuck.enable = true;

    # help manage android devices via command line
    adb.enable = true;

    # show network usage
    bandwhich.enable = true;
  };

  # determine which version of wine to use
  environment.systemPackages = optional config.garden.programs.agnostic.wine.enable (
    if (isWayland config) then pkgs.wineWowPackages.waylandFull else pkgs.wineWowPackages.stableFull
  );
}
