{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf isAcceptedDevice mkGraphicalService;
  acceptedTypes = [
    "desktop"
    "laptop"
    "hybrid"
  ];
in
{
  config = mkIf (isAcceptedDevice osConfig acceptedTypes && pkgs.stdenv.isLinux) {
    home.packages = [ pkgs.nextcloud-client ];

    systemd.user = {
      timers."github-notis" = {
        Install.WantedBy = [ "timers.target" ];
        Timer = {
          OnUnitActiveSec = "30m";
          Unit = "github-notis.service";
        };
      };

      services."github-notis" = mkGraphicalService {
        Unit = {
          Description = "GitHub notifications checker";
          After = "network-online.target";
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${lib.getExe pkgs.gh} api notifications | ${lib.getExe pkgs.jq} 'length'";
        };
      };
    };
  };
}
