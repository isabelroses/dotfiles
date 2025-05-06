{ lib, config, ... }:
let
  inherit (lib) mkIf mkMerge filterAttrs;

  hasBtrfs = (filterAttrs (_: v: v.fsType == "btrfs") config.fileSystems) != { };
in
{
  config = mkMerge [
    {
      # discard blocks that are not in use by the filesystem, good for SSDs health
      services.fstrim = {
        enable = true;
        interval = "weekly";
      };
    }

    # clean btrfs devices
    (mkIf hasBtrfs {
      services.btrfs.autoScrub = {
        enable = true;
        interval = "weekly";
        fileSystems = [ "/" ];
      };
    })
  ];
}
