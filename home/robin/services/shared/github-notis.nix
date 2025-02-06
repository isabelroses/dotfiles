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
  inherit (self.lib.validators) isAcceptedDevice;
  inherit (self.lib.services) mkGraphicalService;

  acceptedTypes = [
    "desktop"
    "laptop"
    "hybrid"
  ];
in
{
  config = mkIf (isAcceptedDevice osConfig acceptedTypes && pkgs.stdenv.hostPlatform.isLinux) {
    systemd.user = {
      timers."github-notis" = {
        Install.WantedBy = [ "timers.target" ];
        Timer = {
          OnUnitActiveSec = "15m";
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
          ExecStart = getExe (
            pkgs.writeShellApplication {
              name = "github-notis";
              runtimeInputs = builtins.attrValues { inherit (pkgs) gh jq libnotify; };
              text = ''
                notis=$(gh api notifications | jq "length")
                if [ "$notis" -gt 0 ]; then
                  notify-send "GitHub" "You have $notis notifications" --icon=github
                fi
              '';
            }
          );
        };
      };
    };
  };
}
