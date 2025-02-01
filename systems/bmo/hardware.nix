{
  fileSystems = {
    "/" = {
      label = "root";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

    "/nix" = {
      label = "store";
      fsType = "btrfs";
      options = [
        "subvol=store"
        "noatime"
      ];
    };

    "/home" = {
      label = "home";
      fsType = "btrfs";
      options = [
        "subvol=home"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];
}
