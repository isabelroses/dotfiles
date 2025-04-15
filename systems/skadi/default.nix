{
  imports = [
    ./hardware.nix
    ./users.nix
  ];

  garden = {
    device = {
      profiles = [
        "headless"
        "server"
      ];
      cpu = "amd";
      gpu = null;
    };

    system = {
      boot = {
        loader = "systemd-boot";
      };
      emulation.enable = true;
    };

    services = {
      nginx.enable = true;
      uptime-kuma.enable = true;
    };
  };
}
