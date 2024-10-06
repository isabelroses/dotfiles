{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isWayland;
in
{
  config = mkIf (isWayland config) {
    systemd.services.seatd = {
      enable = true;
      description = "Seat management daemon";
      script = "${getExe pkgs.seatd} -g wheel";
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "1";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
