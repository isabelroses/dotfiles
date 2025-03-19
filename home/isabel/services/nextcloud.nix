{
  lib,
  self,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) hasProfile;
  inherit (self.lib.services) mkGraphicalService;

  acceptedTypes = [
    "desktop"
    "laptop"
    "hybrid"
  ];
in
{
  config = mkIf (hasProfile osConfig acceptedTypes && pkgs.stdenv.hostPlatform.isLinux) {
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
