{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (pkgs.stdenv.hostPlatform) isLinux;

  palette = inputs.evergarden.lib.util.mkPalette config.evergarden;
in
{
  # screenshot annotation tool
  programs.satty = mkIf (config.garden.profiles.graphical.enable && isLinux) {
    enable = true;

    settings = {
      color-palette = {
        palette = [
          "#${palette.red}"
          "#${palette.orange}"
          "#${palette.yellow}"
          "#${palette.green}"
          "#${palette.skye}"
          "#${palette.pink}"
        ];
      };
    };
  };
}
