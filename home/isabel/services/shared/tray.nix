{
  osConfig,
  lib,
  ...
}: let
  inherit (lib) mkIf isAcceptedDevice;
  acceptedTypes = ["lite" "hybrid" "laptop" "desktop"];
in {
  config = mkIf (isAcceptedDevice osConfig acceptedTypes) {
    # https://github.com/nix-community/home-manager/issues/2064
    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = ["graphical-session-pre.target"];
      };
    };
  };
}
