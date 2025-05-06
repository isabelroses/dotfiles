{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) getExe;
in
{
  systemd.services.seatd = {
    enable = config.garden.profiles.graphical.enable && !config.services.desktopManager.cosmic.enable;
    description = "Seat management daemon";
    script = "${getExe pkgs.seatd} -g wheel";
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "1";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
