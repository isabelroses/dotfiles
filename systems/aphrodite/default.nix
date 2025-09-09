{
  imports = [ ./hardware.nix ];

  garden = {
    profiles = {
      headless.enable = true;
      server.enable = true;
    };

    device = {
      cpu = "intel";
      gpu = null;
    };

    system.boot = {
      loader = "grub";
      grub.device = "/dev/vda";
    };

    services = {
      nginx = {
        enable = true;
        domain = "tgirl.cloud";
      };
      attic.enable = true;
    };
  };
}
