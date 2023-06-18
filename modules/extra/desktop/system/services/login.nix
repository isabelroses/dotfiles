{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  env = config.modules.usrEnv;
  sys = config.modules.system;
in {
  config = {
    # unlock GPG keyring on login
    security.pam.services.login = {
      enableGnomeKeyring = true;
      gnupg = {
        enable = true;
        noAutostart = true;
        storeOnly = true;
      };
    };

    systemd.services = {
      # login manager
      seatd = {
        enable = true;
        description = "Seat management daemon";
        script = "${lib.getExe pkgs.seatd} -g wheel";
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RestartSec = "1";
        };
        wantedBy = ["multi-user.target"];
      };
    };

    services = {
      gnome = {
        glib-networking.enable = true;
        gnome-keyring.enable = true;
      };

      logind.extraConfig = ''
        HandlePowerKey=suspend-then-hibernate
        HandleLidSwtich=ignore
        HandleLidSwitchDocked=ignore
        HandleLidSwitchExternalPower=ignore
      '';
    };
  };
}
