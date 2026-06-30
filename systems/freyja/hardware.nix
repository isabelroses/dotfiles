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
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/975ce62b-2d49-44f4-94cf-f2125eb3defb"; }
  ];
}
