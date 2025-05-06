{
  imports = [
    ./cloud # abstractions for specific cloud providers
    ./cpu # cpu specific options
    ./gpu # gpu specific options
    ./media # sound and video
    ./power # power management

    ./bluetooth.nix # bluetooth
    ./firmwares.nix # firmwares
    ./fs.nix # filesystem tools
    ./options.nix # options to set the cpu and gpu
    ./tpm.nix # Trusted Platform Module
    ./yubikey.nix # yubikey device support and management tools
  ];
}
