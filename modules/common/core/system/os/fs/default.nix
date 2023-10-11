{
  lib,
  config,
  ...
}:
with lib; let
  sys = config.modules.system;
in {
  config = mkMerge [
    (mkIf (builtins.elem "btrfs" sys.fs) {
      # clean btrfs devices
      services.btrfs.autoScrub = {
        enable = true;
        fileSystems = ["/"];
      };

      # fix: initrd.systemd.enable
      boot = {
        supportedFilesystems = ["btrfs"];
        initrd = {
          supportedFilesystems = ["btrfs"];
        };
      };
    })

    (mkIf (builtins.elem "ext4" sys.fs) {
      boot = {
        supportedFilesystems = ["ext4"];
        initrd = {
          supportedFilesystems = ["ext4"];
        };
      };
    })

    (mkIf (builtins.elem "exfat" sys.fs) {
      boot = {
        supportedFilesystems = ["exfat"];
        initrd = {
          supportedFilesystems = ["exfat"];
        };
      };
    })

    # accept both ntfs and ntfs3 as valid values
    (mkIf ((builtins.elem "ntfs" sys.fs) || (builtins.elem "ntfs3" sys.fs)) {
      boot = {
        supportedFilesystems = ["ntfs"];
      };
    })
  ];
}
