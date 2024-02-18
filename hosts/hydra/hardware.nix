{
  lib,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_usb_sdmmc"];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/2cdcddcf-db9e-472f-ab4f-14e7b644beea";
      fsType = "btrfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/2524-71ED";
      fsType = "vfat";
    };
  };

  swapDevices = [{device = "/dev/disk/by-uuid/e45cd5a5-ec02-4933-9adb-5d968f270f54";}];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
