{
  lib,
  self,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) hasProfile;

  acceptedTypes = [
    "lite"
    "hybrid"
    "laptop"
    "desktop"
  ];
in
{
  config = mkIf (hasProfile osConfig acceptedTypes) {
    # https://github.com/nix-community/home-manager/issues/2064
    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = [ "graphical-session-pre.target" ];
      };
    };
  };
}
