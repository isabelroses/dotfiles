{
  lib,
  pkgs,
  osConfig,
  ...
}: let
  rofiPackage =
    if lib.isWayland osConfig
    then pkgs.rofi-wayland
    else pkgs.rofi;
in {
  imports = [./config.nix];

  config = lib.mkIf osConfig.modules.programs.gui.launchers.rofi.enable {
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
