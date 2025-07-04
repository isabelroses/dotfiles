{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/44796f51-4f0a-471b-827b-e7b5a8050110";
      fsType = "btrfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/8C3F-37AD";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    "/home/robin" = {
      device = "/dev/disk/by-uuid/d462c985-8c0c-4be7-98ee-af05dc259ba6";
      fsType = "btrfs";
    };
  };
}
