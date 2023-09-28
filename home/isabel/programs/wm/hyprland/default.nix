{
  pkgs,
  lib,
  osConfig,
  inputs',
  ...
}: let
  inherit (osConfig.modules) device usrEnv;

  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  imports = [./config.nix];
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && lib.isWayland osConfig && usrEnv.desktop == "Hyprland") {
    home.packages = with pkgs;
      [
        grim
        inputs'.hyprpicker.packages.default
      ]
      ++ lib.optionals (usrEnv.programs.nur.enable && usrEnv.programs.nur.bella) [
        nur.repos.bella.catppuccin-hyprland
      ];
    wayland.windowManager.hyprland = {
      enable = true;
      systemdIntegration = true;
      package = inputs'.hyprland.packages.default.override {
        enableNvidiaPatches = (device.gpu == "nvidia") || (device.gpu == "hybrid-nv");
      };
    };
  };
}
