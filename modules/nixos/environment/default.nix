{
  imports = [
    # keep-sorted start
    ./console.nix # changes to the console
    ./documentation.nix # nixos' provided documentation
    ./fonts.nix # fonts
    ./locale.nix # locale settings
    ./packages.nix # core packages for nixos
    ./paths.nix # paths
    ./wayland.nix # wayland settings
    ./xdg.nix # move everything to nice placee
    ./zram.nix # zram optimisation and enabling
    # keep-sorted end
  ];
}
