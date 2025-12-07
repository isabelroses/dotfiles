{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/3ac0d35f-0807-4553-a17e-24b227f1a3b1";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/ED86-8CB2";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };
}
