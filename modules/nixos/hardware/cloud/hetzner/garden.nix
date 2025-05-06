{ lib, config, ... }:
let
  inherit (lib) mkIf;

  cfg = config.garden.profiles.server.hetzner;
in
{
  config = mkIf cfg.enable {
    garden = {
      device = {
        hasTPM = false;
        hasBluetooth = false;
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
