{
  imports = [
    ./hardware.nix
    ./users.nix
  ];

  garden = {
    profiles = {
      headless.enable = true;
      server.enable = true;

      hetzner.enable = true;
    };

    # AMD EPYC-Rome, no gpu
    device.cpu = "vm-amd";
  };
}
