{
  osConfig,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf isAcceptedDevice;
  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  config = mkIf ((isAcceptedDevice osConfig acceptedTypes) && osConfig.modules.programs.cli.enable) {
    home.packages = with pkgs; [
      libnotify # needed for some notifcations
      bitwarden-cli # bitwarden, my chosen package manager
      trash-cli # `rm` skips the "rubish bin", this cli tool uses that
      brightnessctl # brightness managed via cli
    ];
  };
}
