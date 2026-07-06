{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/3a898325-08a7-4f9f-ab19-380765bcaf92";
      fsType = "btrfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/36A9-4288";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/55606623-362b-4c53-a9da-26ea202aff23"; }
  ];
}
