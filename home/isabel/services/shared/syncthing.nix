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
    "hybrid"
  ];
in
{
  config = mkIf (isAcceptedDevice osConfig acceptedTypes) {
    services.syncthing = {
      enable = true;
      tray.enable = pkgs.stdenv.isLinux && osConfig.garden.programs.gui.enable;
    };
  };
}
