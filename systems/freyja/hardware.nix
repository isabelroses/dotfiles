{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/b431ca51-9fd3-48b2-bc60-642c57e4df09";
      fsType = "btrfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/61A5-D03F";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    "/media" = {
      device = "/dev/disk/by-uuid/65d0801f-b72b-4a8f-84bf-115a5a4839ef";
      fsType = "ext4";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/975ce62b-2d49-44f4-94cf-f2125eb3defb"; }
  ];
}
