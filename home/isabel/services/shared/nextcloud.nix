{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isAcceptedDevice;
  inherit (lib.services) mkGraphicalService;

  acceptedTypes = [
    "desktop"
    "laptop"
    "hybrid"
  ];
in
{
  config = mkIf (isAcceptedDevice osConfig acceptedTypes && pkgs.stdenv.isLinux) {
    home.packages = [ pkgs.nextcloud-client ];

    systemd.user.services.nextcloud = mkGraphicalService {
      Unit = {
        Description = "Nextcloud sync client service";
        After = "network-online.target";
      };

      Service = {
        ExecStart = "${getExe pkgs.nextcloud-client} --background";
        Restart = "always";
        Slice = "background.slice";
      };
    };
  };
}
