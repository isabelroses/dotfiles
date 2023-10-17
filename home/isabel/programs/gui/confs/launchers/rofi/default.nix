{
  config,
  lib,
  pkgs,
  osConfig,
  defaults,
  ...
}: let
  acceptedTypes = ["laptop" "desktop" "hybrid" "lite"];

  rofiPackage =
    if lib.isWayland osConfig
    then pkgs.rofi-wayland
    else pkgs.rofi;
in {
  imports = [./config.nix];

  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && osConfig.modules.programs.gui.enable && defaults.launcher == "rofi") {
    programs.rofi = {
      enable = true;
      package = rofiPackage.override {
        plugins = [
          pkgs.rofi-rbw
        ];
      };
    };
  };
}
