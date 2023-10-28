{
  lib,
  osConfig,
  pkgs,
  ...
}: let
  inherit (lib) mkIf isAcceptedDevice mkGraphicalService;
  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  config = mkIf (isAcceptedDevice osConfig acceptedTypes) {
    /*
    services = {
      nextcloud-client.enable = true;
      nextcloud-client.startInBackground = true;
    };
    */

    home.packages = [pkgs.nextcloud-client];

    systemd.user.services.nextcloud = mkGraphicalService {
      Unit = {
        Description = "Nextcloud sync client service";
        After = "network-online.target";
      };

      Service = {
        ExecStart = "${pkgs.nextcloud-client}/bin/nextcloud --background";
        Restart = "always";
        Slice = "background.slice";
      };
    };
  };
}
