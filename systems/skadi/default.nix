{
  imports = [ ./hardware.nix ];

  garden = {
    profiles = {
      headless.enable = true;
      server.enable = true;

      oracle = {
        enable = true;

        ipv4 = "10.0.0.11";
        ipv6 = "2603:c020:c011:9c00:0:c069:1ff7:1ff3";
      };
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
