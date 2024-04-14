{
  lib,
  pkgs,
  config,
  ...
}: {
  # determine which version of wine to use
  environment.systemPackages = with pkgs; let
    winePackage =
      if (lib.isWayland config)
      then wineWowPackages.waylandFull
      else wineWowPackages.stableFull;
  in
    lib.mkIf config.modules.programs.agnostic.wine.enable [winePackage];
}
