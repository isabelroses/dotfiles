{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isAcceptedDevice;
  inherit (lib.lists) optionals;

  acceptedTypes = [
    "desktop"
    "laptop"
    "lite"
    "hybrid"
  ];

  cfg = osConfig.garden.programs;
in
{
  config = mkIf ((isAcceptedDevice osConfig acceptedTypes) && cfg.cli.enable && cfg.gui.enable) {
    home.packages =
      with pkgs;
      [
        libnotify # needed for some notifications
        bitwarden-cli # bitwarden, my chosen password manager
        trash-cli # `rm` skips the "rubish bin", this cli tool uses that
        brightnessctl # brightness managed via cli
        dconf # interface with dconf settings
      ]
      ++ optionals cfg.cli.modernShell.enable [ catppuccinifier-cli ];
  };
}
