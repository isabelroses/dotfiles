{
  imports = [
    ./hardware.nix
    ./users.nix
  ];

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
      emulation.enable = true;
    };

    services = {
      nginx.enable = true;
      uptime-kuma.enable = true;
      ntfy.enable = true;
    };
  };
}
