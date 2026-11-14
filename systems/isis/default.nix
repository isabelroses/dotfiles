{
  imports = [ ./hardware.nix ];

  garden = {
    profiles = {
      headless.enable = true;
      server.enable = true;
      upcloud.enable = true;
    };

    # AMD EPYC 9575F, no gpu
    device.cpu = "vm-amd";
  };
}
