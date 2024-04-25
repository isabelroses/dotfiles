{
  lib,
  config,
  ...
}: {
  config = {
    services.smartd.enable = lib.mkForce false; # Unavailable - device lacks SMART capability.

    boot = {
      growPartition = !config.boot.initrd.systemd.enable;
      kernelParams = ["net.ifnames=0"];
      kernel = {
        sysctl = {
          "net.ipv4.ip_forward" = true;
          "net.ipv6.conf.all.forwarding" = true;
        };
      };

      loader.grub = {
        enable = true;
        useOSProber = lib.mkForce false;
        efiSupport = lib.mkForce false;
        enableCryptodisk = false;
        theme = lib.mkForce null;
        backgroundColor = lib.mkForce null;
        splashImage = lib.mkForce null;
        device = lib.mkForce "/dev/sda";
      };
    };
  };
}
