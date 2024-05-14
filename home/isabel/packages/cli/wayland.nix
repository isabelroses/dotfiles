{
  osConfig,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (lib.isWayland osConfig && osConfig.modules.programs.cli.enable) {
    home.packages = with pkgs; [
      grim
      slurp
      wl-clipboard
      cliphist
    ];
  };
}
