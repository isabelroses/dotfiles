{
  lib,
  osConfig,
  pkgs,
  ...
}: let
  inherit (lib) mkIf isAcceptedDevice mkGraphicalService;
  acceptedTypes = ["desktop" "laptop" "hybrid"];
in {
  config = mkIf (isAcceptedDevice osConfig acceptedTypes && pkgs.stdenv.isLinux) {
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
