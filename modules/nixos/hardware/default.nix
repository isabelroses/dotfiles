{
  imports = [
    # keep-sorted start
    ./bluetooth.nix # bluetooth
    ./cloud # abstractions for specific cloud providers
    ./cpu # cpu specific options
    ./firmwares.nix # firmwares
    ./fs.nix # filesystem tools
    ./gpu # gpu specific options
    ./media # sound and video
    ./options.nix # options to set the cpu and gpu
    ./power # power management
    ./tpm.nix # Trusted Platform Module
    ./yubikey.nix # yubikey device support and management tools
    # keep-sorted end
  ];
}
