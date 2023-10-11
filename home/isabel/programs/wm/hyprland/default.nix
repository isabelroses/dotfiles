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
    home.packages = with pkgs; [
      grim
      inputs'.hyprpicker.packages.default
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs'.hyprland.packages.default;
      enableNvidiaPatches = (device.gpu == "nvidia") || (device.gpu == "hybrid-nv");
      xwayland.enable = true;

      systemd = {
        enable = true;
        variables = ["--all"];
      };
    };
  };
}
