{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-label/SYSTEM";
      fsType = "vfat";
    };

    "/home/kitchen" = {
      device = "/dev/disk/by-label/Dolphin";
      fsType = "ntfs-3g";
      options = [
        "rw"
        "uid=1000"
      ];
    };

    "/home/comfy" = {
      device = "/dev/disk/by-label/tanuki";
      fsType = "ext4";
    };
  };
}
