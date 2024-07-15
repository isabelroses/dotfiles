{
  fileSystems = {
    "/" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };

    "/srv/storage" = {
      device = "/dev/disk/by-id/scsi-0HC_Volume_37980392";
      fsType = "ext4";
    };
  };
}
