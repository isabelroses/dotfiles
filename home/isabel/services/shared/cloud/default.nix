{
  lib,
  osConfig,
  pkgs,
  ...
}: let
  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && (lib.isWayland osConfig)) {
    /*
    services = {
      nextcloud-client.enable = true;
      nextcloud-client.startInBackground = true;
    };
    */

    home.packages = [pkgs.nextcloud-client];

    systemd.user.services.nextcloud = lib.mkGraphicalService {
      Unit.Description = "Nextcloud client service";
      Service = {
        ExecStart = "${pkgs.nextcloud-client}/bin/nextcloud --background";
        Restart = "always";
        Slice = "background.slice";
      };
    };
  };
}
