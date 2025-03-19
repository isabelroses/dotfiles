{
  lib,
  self,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) hasProfile;

  acceptedTypes = [
    "desktop"
    "laptop"
    "hybrid"
  ];
in
{
  config = mkIf (hasProfile osConfig acceptedTypes) {
    services.syncthing = {
      enable = true;

      tray = {
        enable = pkgs.stdenv.hostPlatform.isLinux && config.garden.programs.gui.enable;
        command = "syncthingtray --wait";
      };
    };
  };
}
