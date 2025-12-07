{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.garden.profiles.hetzner;
in
{
  options.garden.profiles.hetzner = {
    enable = mkEnableOption "Hetzner Cloud profile";
  };

  config = mkIf cfg.enable {
    garden = {
      device.capabilities = {
        tpm = false;
        bluetooth = false;
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

        bluetooth.enable = false;

        networking = {
          optimizeTcp = false;
        };
      };
    };
  };
}
