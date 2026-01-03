{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/2cdcddcf-db9e-472f-ab4f-14e7b644beea";
      fsType = "btrfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/2524-71ED";
      fsType = "vfat";
    };

    "/media" = {
      device = "/dev/disk/by-uuid/c4f7c302-f492-47dd-8bfd-e3073c1923bd";
      fsType = "ext4";
    };
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/e45cd5a5-ec02-4933-9adb-5d968f270f54"; } ];
}
