{ lib, ... }:
{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4d503c5f-c51a-4eca-993c-5beb9b85b963";
    fsType = "ext4";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/9455e246-4f8f-42cb-beb8-d1a071a1b5e0"; }
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
