{
  pkgs,
  lib,
  osConfig,
  inputs',
  ...
}:
with lib; let
  hyprpicker = inputs'.hyprpicker.packages.default;
  hyprland-share-picker = inputs'.xdg-portal-hyprland.packages.xdg-desktop-portal-hyprland;

  env = osConfig.modules.usrEnv;
  device = osConfig.modules.device;
  sys = osConfig.modules.system;
in {
  imports = [./config.nix];
  config = mkIf ((sys.video.enable) && (env.isWayland && (env.desktop == "Hyprland"))) {
    home.packages = with pkgs; [
      grim
      hyprpicker
      hyprland-share-picker
      nur.repos.bella.catppuccin-hyprland
    ];
    wayland.windowManager.hyprland = {
      enable = true;
      systemdIntegration = true;
      package = inputs'.hyprland.packages.default.override {
        nvidiaPatches = (device.gpu == "nvidia") || (device.gpu == "hybrid-nv");
      };
    };
  };
}
