{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/77a90bab-9a6f-4cf0-8493-7db518b9214a";
      fsType = "ext4";
    };

    "/efi" = {
      device = "/dev/disk/by-uuid/88C6-A9EA";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    "/srv/storage" = {
      device = "/dev/disk/by-uuid/157ffe4f-f8f9-4d20-b2e1-3dc144941729";
      fsType = "ext4";
    };
  };
}
