{ lib, ... }:
{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ecbc167c-3bfe-4801-90c1-51c272d316c6";
    fsType = "ext4";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/a04ef6f2-82fe-4a8c-9273-fb80e7383dfa"; }
  ];

  services = {
    smartd.enable = lib.mkForce false;
    qemuGuest.enable = true;
  };

  boot = {
    loader.generationsDir.copyKernels = lib.mkForce false;

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
      useOSProber = lib.mkForce false;
      efiSupport = lib.mkForce false;
    };
  };
}
