{
  imports = [
    ./cpu # cpu specific options
    ./gpu # gpu specific options
    ./media # sound and video
    ./cloud # abstractions for specific cloud providers

    ./bluetooth.nix # bluetooth
    ./firmwares.nix # firmwares
    ./options.nix # options to set the cpu and gpu
    ./tpm.nix # Trusted Platform Module
    ./yubikey.nix # yubikey device support and management tools
  ];
}
