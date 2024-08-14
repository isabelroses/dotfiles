{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.garden.system.fs;
in
{
  options.garden.system.fs = {
    enableDefaults = mkEnableOption "Enable default filesystems";
    enableSwap = mkEnableOption "Enable swap";
  };

  config = mkIf cfg.enableDefaults {
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/root";
        fsType = "btrfs";
      };

      "/boot" = {
        device = "/dev/disk/by-label/boot";
        fsType = "vfat";
      };
    };

    swapDevices = mkIf cfg.enableSwap [ { device = "/dev/disk/by-label/swap"; } ];
  };
}
