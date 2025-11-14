{ lib, ... }:
{

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/71fc32ae-cc42-4020-a9ab-03b2b79d89c5";
    fsType = "ext4";
  };

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
