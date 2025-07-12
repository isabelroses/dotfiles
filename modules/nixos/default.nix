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
    # keep-sorted end
  ];
}
