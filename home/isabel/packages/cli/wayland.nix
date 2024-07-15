{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isWayland;
  cfg = osConfig.garden.programs;
in
{
  config = mkIf (isWayland osConfig && cfg.cli.enable && cfg.gui.enable) {
    home.packages = with pkgs; [
      grim
      slurp
      wl-clipboard
      cliphist
    ];
  };
}
