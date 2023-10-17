{
  osConfig,
  lib,
  pkgs,
  ...
}:
with lib; let
  programs = osConfig.modules.programs;
  device = osConfig.modules.device;

  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  config = mkIf ((builtins.elem device.type acceptedTypes) && (programs.cli.enable)) {
    home.packages = with pkgs; [
      # CLI
      libnotify
      imagemagick
      bitwarden-cli
      trash-cli
      brightnessctl
    ];
  };
}
