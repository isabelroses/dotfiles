{ lib, config, ... }:
let
  inherit (lib.modules) mkIf mkDefault;

  cfg = config.garden.system;
in
{
  config = mkIf (cfg.boot.loader == "grub") {
    boot.loader.grub = {
      enable = mkDefault true;
      useOSProber = true;
      efiSupport = true;
      enableCryptodisk = mkDefault false;
      inherit (cfg.boot.grub) device;
      theme = null;
      backgroundColor = null;
      splashImage = null;
    };
  };
}
