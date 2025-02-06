{
  lib,
  self,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) isWayland;
  cfg = config.garden.programs;
in
{
  config = mkIf (isWayland osConfig && cfg.cli.enable && cfg.gui.enable) {
    garden.packages = {
      inherit (pkgs)
        grim
        slurp
        wl-clipboard
        cliphist
        ;
    };
  };
}
