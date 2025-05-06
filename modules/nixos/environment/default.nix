{
  imports = [
    ./console.nix # changes to the console
    ./documentation.nix # nixos' provided documentation
    ./locale.nix # locale settings
    ./paths.nix # paths
    ./wayland.nix # wayland settings
    ./xdg.nix # move everything to nice placee
    ./zram.nix # zram optimisation and enabling
  ];
}
