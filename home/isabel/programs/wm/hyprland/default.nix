{
  pkgs,
  lib,
  osConfig,
  inputs',
  ...
}: let
  inherit (osConfig.modules) usrEnv;

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
      xwayland.enable = true;

      systemd = {
        enable = true;
        variables = ["--all"];
      };
    };
  };
}
