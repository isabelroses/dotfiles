{ lib, config, ... }:
let
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.options) mkOption;
  inherit (lib.types) nullOr str;
  cfg = config.garden.system.boot;
in
{
  options.garden.system.boot.grub = {
    device = mkOption {
      type = nullOr str;
      default = "nodev";
      description = "The device to install the bootloader to.";
    };
  };

  config = mkIf (cfg.loader == "grub") {
    boot.loader.grub = {
      enable = mkDefault true;
      useOSProber = true;
      efiSupport = true;
      enableCryptodisk = mkDefault false;
      inherit (cfg.grub) device;
      theme = null;
      backgroundColor = null;
      splashImage = null;
    };
  };
}
