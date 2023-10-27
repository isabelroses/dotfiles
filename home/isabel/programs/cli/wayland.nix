{
  osConfig,
  lib,
  pkgs,
  ...
}: let
  acceptedTypes = ["laptop" "desktop" "hybrid" "lite"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && (lib.isWayland osConfig) && osConfig.modules.programs.cli.enable) {
    home.packages = with pkgs; [
      grim
      slurp
      wl-clipboard
      cliphist
    ];
  };
}
