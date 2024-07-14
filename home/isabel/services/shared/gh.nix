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
          ExecStart = lib.getExe (
            pkgs.writeShellApplication {
              name = "github-notis";
              runtimeInputs = with pkgs; [
                gh
                jq
              ];
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
