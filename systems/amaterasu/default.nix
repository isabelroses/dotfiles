{
  imports = [
    ./hardware.nix
    ./users.nix
  ];

  garden = {
    profiles = {
      graphical.enable = true;
      workstation.enable = true;
      gaming.enable = true;
    };

    device = {
      cpu = "intel";
      gpu = "nvidia";
      monitors = {
        "DP-1" = {
          hz = 144;
          position = "1920x0";
        };
        "DP-2" = {
          hz = 144;
          position = "0x0";
        };
      };
      capabilities = {
        tpm = true;
        bluetooth = true;
        yubikey = true;
      };
      keyboard = "us";
    };

    system = {
      boot = {
        loader = "systemd-boot";
        # secureBoot = true;
      };

      bluetooth.enable = true;
      printing.enable = false;
      emulation.enable = true;

      security.auditd.enable = true;
    };
  };
}
