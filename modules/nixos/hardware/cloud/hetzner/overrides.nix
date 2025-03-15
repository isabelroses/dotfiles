{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf mkForce;
  cfg = config.garden.device.hetzner;
in
{
  config = mkIf cfg.enable {
    services = {
      smartd.enable = mkForce false; # Unavailable - device lacks SMART capability.

      # Needed by the Hetzner Cloud password reset feature
      qemuGuest.enable = true;
    };

    systemd.services.qemu-guest-agent.path = [ pkgs.shadow ];

    boot = {
      growPartition = !config.boot.initrd.systemd.enable;
      kernelParams = [ "net.ifnames=0" ];
      kernel.sysctl = {
        "net.ipv4.ip_forward" = true;
        "net.ipv6.conf.all.forwarding" = true;
      };

      initrd = {
        availableKernelModules = [
          "ata_piix"
          "uhci_hcd"
          "xen_blkfront"
          "vmw_pvscsi"

          "virtio_net"
          "virtio_pci"
          "virtio_mmio"
          "virtio_blk"
          "virtio_scsi"
          "9p"
          "9pnet_virtio"
        ];
        kernelModules = [
          "nvme"
          "virtio_balloon"
          "virtio_console"
          "virtio_rng"
          "virtio_gpu"
        ];
      };

      loader.grub = {
        useOSProber = mkForce false;
        efiSupport = mkForce false;
      };
    };
  };
}
