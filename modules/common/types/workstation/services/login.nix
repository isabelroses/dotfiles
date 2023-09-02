{
  config,
  lib,
  pkgs,
  self,
  inputs,
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
      xserver = {
        enable = true;
        displayManager.sddm = lib.mkIf config.modules.usrEnv.programs.sddm.enable {
          enable = true;
          theme = "${import ../../../../../parts/pkgs/sddm.nix {inherit pkgs lib;}}";
          settings = {
            General = {InputMethod = "";};
          };
        };
      };

      gnome = {
        gnome-keyring.enable = true;
      };

      logind = {
        lidSwitch = "ignore";
        lidSwitchDocked = "ignore";
        lidSwitchExternalPower = "ignore";
        powerKey = "suspend-then-hibernate";
      };
    };
  };
}
