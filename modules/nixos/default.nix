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
    ./networking
    ./nix.nix
    ./programs
    ./security
    ./services
    ./system
    # keep-sorted end
  ];
}
