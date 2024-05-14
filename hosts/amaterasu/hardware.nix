{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/f26dd3a6-7750-4e1e-a465-97fa9e9b9cc6";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/9AD9-AD9F";
      fsType = "vfat";
    };
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/da541a24-b4cc-426f-bbb6-4cced93fa4cf"; } ];
}
