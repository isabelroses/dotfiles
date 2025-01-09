{ lib, config, ... }:
let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) listOf str;
  inherit (lib.options) mkOption;
  inherit (lib.lists) elem map;

  # we remap ntfs3 to ntfs as they are the same thing for nix
  fs = map (f: { ntfs3 = "ntfs"; }.${f} or f) config.garden.system.fs.support;
in
{
  options.garden.system.fs.support = mkOption {
    type = listOf str;
    default = [
      "vfat"
      "ext4"
    ];
    description = ''
      A list of filesystems available supported by the system
      it will enable services based on what strings are found in the list.

      It would be a good idea to keep vfat and ext4 so you can mount USBs.
    '';
  };

  config = mkMerge [
    {
      # discard blocks that are not in use by the filesystem, good for SSDs health
      services.fstrim = {
        enable = true;
        interval = "weekly";
      };

      # include our allowed file systems in the supported fileSystems lists
      boot = {
        supportedFilesystems = fs;
        initrd.supportedFilesystems = fs;
      };
    }

    # clean btrfs devices
    (mkIf (elem "btrfs" fs) {
      services.btrfs.autoScrub = {
        enable = true;
        interval = "weekly";
        fileSystems = [ "/" ];
      };
    })

    (mkIf (fs == [ ]) {
      warnings = [
        ''
          You have not set any filesystems in your configuration. This is not recommended
          as it may lead to a unusable system.

          Please set {option}`config.garden.system.fs` in your configuration to remedy this.
        ''
      ];
    })
  ];
}
