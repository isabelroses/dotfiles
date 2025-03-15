{ lib, ... }:
{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "ext4";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];

  boot.loader.generationsDir.copyKernels = lib.modules.mkForce false;
}
