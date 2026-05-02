{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

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

      system.boot = {
        loader = "grub";
        grub.device = "/dev/sda";
        tmpOnTmpfs = false;
      };
    };
  };
}
