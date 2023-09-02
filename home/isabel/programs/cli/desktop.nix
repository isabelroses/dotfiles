{
  osConfig,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf isAcceptedDevice;
  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  config = mkIf ((isAcceptedDevice osConfig acceptedTypes) && osConfig.modules.usrEnv.programs.cli.enable) {
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
