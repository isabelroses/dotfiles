{
  _class = "nixos";

  imports = [
    # keep-sorted start
    ../base
    ./boot
    ./catppuccin.nix
    ./emulation.nix
    ./environment
    ./extras.nix
    ./hardware
    ./headless.nix
    ./kernel
    ./networking
    ./nix.nix
    ./programs
    ./secrets.nix
    ./security
    ./services
    ./system
    ./users
    # keep-sorted end
  ];
}
