{ config, ... }:
{
  # discard blocks that are not in use by the filesystem, good for SSDs health
  services = {
    fstrim = {
      enable = true;
      interval = "weekly";
    };

    # clean btrfs devices
    btrfs.autoScrub = {
      enable = config.boot.supportedFilesystems.btrfs or false;
      interval = "weekly";
      fileSystems = [ "/" ];
    };
  };
}
