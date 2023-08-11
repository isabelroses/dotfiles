{
  config,
  pkgs,
  ...
}: {
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
        script = "${pkgs.seatd}/bin/seatd -g wheel";
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
