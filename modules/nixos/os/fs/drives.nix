{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.garden.system.fs;
in
{
  options.garden.system.fs.enableDefaults = mkEnableOption "Enable default filesystems";

  config.fileSystems = mkIf cfg.enableDefaults {
    "/" = {
      device = "/dev/disk/by-label/ROOT";
      fsType = "btrfs";
    };

    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };
  };
}
