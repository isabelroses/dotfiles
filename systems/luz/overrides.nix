{
  lib,
  config,
  modulesPath,
  ...
}:
let
  inherit (lib.modules) mkForce;
in
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  config = {
    services.smartd.enable = mkForce false; # Unavailable - device lacks SMART capability.

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
        useOSProber = mkForce false;
        efiSupport = mkForce false;
        enableCryptodisk = false;
        theme = mkForce null;
        backgroundColor = mkForce null;
        splashImage = mkForce null;
        device = mkForce "/dev/sda";
      };
    };
  };
}
