{
  imports = [ ./hardware.nix ];

  garden = {
    profiles = {
      headless.enable = true;
      server.enable = true;
      oracle.enable = true;
    };

    device = {
      cpu = null;
      gpu = null;
    };

    system = {
      boot = {
        loader = "systemd-boot";
        initrd.tweaks.enable = false;
      };
    };

    services = {
      nginx.enable = true;
      gatus.enable = true;
      pds.enable = true;
      piper.enable = true;
    };
  };
}
