{
  osConfig,
  lib,
  pkgs,
  inputs',
  self',
  ...
}: let
  inherit (lib) mkIf isAcceptedDevice optionals;
  acceptedTypes = ["desktop" "laptop" "wsl" "lite" "hybrid"];

  cfg = osConfig.modules.programs;
in {
  config = mkIf ((isAcceptedDevice osConfig acceptedTypes) && cfg.cli.enable && cfg.gui.enable) {
    home.packages = with pkgs;
      [
        libnotify # needed for some notifcations
        bitwarden-cli # bitwarden, my chosen password manager
        trash-cli # `rm` skips the "rubish bin", this cli tool uses that
        brightnessctl # brightness managed via cli
      ]
      ++ optionals cfg.cli.modernShell.enable [
        inputs'.catppuccin-toolbox.packages.catwalk
        self'.packages.catppuccinifier-cli
      ];
  };
}
