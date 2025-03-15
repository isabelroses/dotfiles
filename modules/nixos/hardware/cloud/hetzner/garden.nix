{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.garden.device.hetzner;
in
{
  options.garden.device.hetzner = {
    enable = mkEnableOption "hetzner";
  };

  config = mkIf cfg.enable {
    garden = {
      device = {
        hasTPM = false;
        hasBluetooth = false;
        hasSound = false;
      };

      system = {
        boot = {
          loader = "grub";
          grub.device = "/dev/sda";
          enableKernelTweaks = true;
          initrd.enableTweaks = true;
          loadRecommendedModules = true;
          tmpOnTmpfs = false;
        };

        fs.support = [
          "vfat"
          "exfat"
          "ext4"
        ];

        video.enable = false;
        sound.enable = false;
        bluetooth.enable = false;

        networking = {
          optimizeTcp = false;
        };
      };
    };
  };
}
