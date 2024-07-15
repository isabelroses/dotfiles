{ lib, config, ... }:
let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) listOf str;
  inherit (lib.options) mkOption;
  inherit (lib.lists) elem;

  inherit (config.garden.system) fs;
in
{
  options.garden.system.fs = mkOption {
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
    (mkIf (fs == [ ]) {
      warnings = [
        ''
          You have not added any filesystems to be supported by your system. You may end up with an unbootable system!

          Consider setting {option}`config.garden.system.fs` in your configuration
        ''
      ];
    })

    (mkIf (elem "btrfs" fs) {
      # clean btrfs devices
      services.btrfs.autoScrub = {
        enable = true;
        fileSystems = [ "/" ];
      };

      # fix: initrd.systemd.enable
      boot = {
        supportedFilesystems = [ "btrfs" ];
        initrd = {
          supportedFilesystems = [ "btrfs" ];
        };
      };
    })

    (mkIf (elem "ext4" fs) {
      boot = {
        supportedFilesystems = [ "ext4" ];
        initrd = {
          supportedFilesystems = [ "ext4" ];
        };
      };
    })

    (mkIf (elem "exfat" fs) {
      boot = {
        supportedFilesystems = [ "exfat" ];
        initrd = {
          supportedFilesystems = [ "exfat" ];
        };
      };
    })

    # accept both ntfs and ntfs3 as valid values
    (mkIf ((elem "ntfs" fs) || (elem "ntfs3" fs)) {
      boot = {
        supportedFilesystems = [ "ntfs" ];
      };
    })
  ];
}
