{ lib, ... }:
{
  imports = [
    ./cpu # cpu specific options
    ./gpu # gpu specific options
    ./media # sound and video

    ./bluetooth.nix # bluetooth
    ./options.nix # options to set the cpu and gpu
    ./tpm.nix # Trusted Platform Module
    ./yubikey.nix # yubikey device support and management tools
  ];

  config = {
    hardware.enableRedistributableFirmware = lib.modules.mkDefault true;
  };
}
