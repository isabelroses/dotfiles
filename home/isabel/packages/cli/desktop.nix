{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isAcceptedDevice;

  acceptedTypes = [
    "desktop"
    "laptop"
    "lite"
    "hybrid"
  ];

  cfg = osConfig.garden.programs;
in
{
  config = mkIf (isAcceptedDevice osConfig acceptedTypes && cfg.cli.enable && cfg.gui.enable) {
    home.packages = builtins.attrValues {
      inherit (pkgs)
        libnotify # needed for some notifications
        # bitwarden-cli # bitwarden, my chosen password manager
        brightnessctl # brightness managed via cli
        ;
    };
  };
}
