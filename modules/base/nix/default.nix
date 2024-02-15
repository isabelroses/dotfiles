{
  imports = [
    ./environment.nix # environment settings that nix requires
    ./nix.nix # nix the package manager's settings
    ./nixpkgs.nix # nixpkgs configuration
    ./system.nix # system settings that nix needs
  ];
}
