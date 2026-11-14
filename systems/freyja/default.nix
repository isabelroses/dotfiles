{
  imports = [
    ./hardware.nix
  ];

  garden = {
    profiles = {
      server.enable = true;
      headless.enable = true;
    };

    device = {
      cpu = "amd";
      gpu = "nvidia";
      capabilities = {
        tpm = true;
      };
    };

    system = {
      boot.loader = "systemd-boot";

      networking.useRouterDns = true;
    };
  };

  # where to advertise the thread mesh, only used once the radio is set
  services.openthread-border-router.backboneInterfaces = [ "enp6s0" ];
}
