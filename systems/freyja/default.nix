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

    system.boot.loader = "systemd-boot";
  };
}
