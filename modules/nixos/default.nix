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
    ./gaming
    ./hardware
    ./headless.nix
    ./networking
    ./nix.nix
    ./programs
    ./secrets.nix
    ./security
    ./services
    ./system
    ./tags.nix
    ./topology.nix
    ./users
    # keep-sorted end
  ];
}
