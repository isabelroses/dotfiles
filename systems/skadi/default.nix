{
  imports = [ ./hardware.nix ];

  garden = {
    profiles = {
      headless.enable = true;
      server.enable = true;

      oracle.enable = true;
    };

    # ampere altra, aarch64
    device.cpu = null;

    system = {
      boot = {
        loader = "systemd-boot";
        initrd.tweaks.enable = false;
      };
    };
  };
}
