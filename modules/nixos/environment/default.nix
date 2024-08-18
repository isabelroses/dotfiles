{
  imports = [
    ./console.nix # changes to the console
    ./documentation.nix # nixos' provided documentation
    ./etc.nix # misc
    ./locale.nix # locale settings
    ./paths.nix # paths
    ./xdg.nix # move everything to nice placee
    ./zram.nix # zram optimisation and enabling
  ];
}
