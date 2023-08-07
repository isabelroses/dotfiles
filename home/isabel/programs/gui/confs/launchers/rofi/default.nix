{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
with lib; let
  device = osConfig.modules.device;
  acceptedTypes = ["laptop" "desktop" "hybrid" "lite"];
  sys = osConfig.modules.system;
  programs = osConfig.modules.programs;

  rofiPackage =
    if osConfig.modules.usrEnv.isWayland
    then pkgs.rofi-wayland
    else pkgs.rofi;
in {
  imports = [./config.nix];
  config = mkIf (builtins.elem device.type acceptedTypes && sys.video.enable && programs.gui.enable && programs.default.launcher == "rofi") {
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
