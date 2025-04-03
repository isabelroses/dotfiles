{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.programs) mkProgram;
  inherit (self.lib.validators) isWayland;

  cfg = config.garden.programs.wine;
in
{
  options.garden.programs.wine = mkProgram pkgs "wine" {
    package.default =
      if isWayland config then pkgs.wineWowPackages.waylandFull else pkgs.wineWowPackages.stableFull;
  };

  # determine which version of wine to use
  config = mkIf cfg.enable {
    garden.packages = { inherit (cfg) package; };
  };
}
