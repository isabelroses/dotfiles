{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf getExe isWayland;
in
{
  config = mkIf (isWayland config && pkgs.stdenv.isLinux) {
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
