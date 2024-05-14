{ lib, ... }:
{
  imports = [
    ./cpu # cpu specific options
    ./gpu # gpu specific options
    ./media # sound and video

    ./bluetooth.nix # bluetooth
    ./tmp.nix # Trusted Platform Module
    ./yubikey.nix # yubikey device support and management tools
  ];

  config = {
    hardware.enableRedistributableFirmware = lib.mkDefault true;
  };
}
