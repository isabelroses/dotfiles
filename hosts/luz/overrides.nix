{
  lib,
  config,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  config = {
    services.smartd.enable = lib.mkForce false; # Unavailable - device lacks SMART capability.

    boot = {
      growPartition = !config.boot.initrd.systemd.enable;
      kernelParams = [ "net.ifnames=0" ];
      kernel = {
        sysctl = {
          "net.ipv4.ip_forward" = true;
          "net.ipv6.conf.all.forwarding" = true;
        };
      };

      initrd.availableKernelModules = [
        "uhci_hcd"
        "xen_blkfront"
        "vmw_pvscsi"
      ];

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
