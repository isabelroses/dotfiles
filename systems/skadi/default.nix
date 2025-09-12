{
  imports = [ ./hardware.nix ];

  garden = {
    profiles = {
      headless.enable = true;
      server.enable = true;
    };

    device = {
      cpu = "amd";
      gpu = null;
    };

    system = {
      boot.loader = "systemd-boot";
    };

    services = {
      nginx.enable = true;
      uptime-kuma.enable = true;
      ntfy.enable = true;
      pds.enable = true;
    };
  };
}
