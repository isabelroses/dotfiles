{
  lib,
  pkgs,
  config,
  ...
}:
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
  environment.systemPackages =
    with pkgs;
    let
      winePackage =
        if (lib.isWayland config) then wineWowPackages.waylandFull else wineWowPackages.stableFull;
    in
    lib.mkIf config.garden.programs.agnostic.wine.enable [ winePackage ];
}
