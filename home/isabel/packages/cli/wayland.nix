{
  osConfig,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (lib.isWayland osConfig && osConfig.garden.programs.cli.enable) {
    home.packages = with pkgs; [
      grim
      slurp
      wl-clipboard
      cliphist
    ];
  };
}
