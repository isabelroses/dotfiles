{
  pkgs,
  lib,
  osConfig,
  inputs',
  ...
}: let
  inherit (osConfig.modules) environment;
in {
  imports = [./config.nix];
  config = lib.mkIf (lib.isWayland osConfig && environment.desktop == "Hyprland") {
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
