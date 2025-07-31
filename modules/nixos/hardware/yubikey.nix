{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
in
{
  options.garden.device.capabilities.yubikey = mkEnableOption "yubikey support";

  config = mkIf config.garden.device.capabilities.yubikey {
    services = {
      pcscd.enable = true;
      udev.packages = [ pkgs.yubikey-personalization ];
    };

    hardware.gpgSmartcards.enable = true;

    # Yubico's official tools
    garden.packages = {
      inherit (pkgs) yubikey-manager;
    };
  };
}
