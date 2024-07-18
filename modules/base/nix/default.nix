{
  imports = [
    ./overlays # nixpkgs overlays for custom packages and patches
    ./environment.nix # environment settings that nix requires
    ./nh.nix # a nix helper cli
    ./nix.nix # nix the package manager's settings
    ./nixpkgs.nix # nixpkgs configuration
    ./substituters.nix # nixpkgs substituters
    ./system.nix # system settings that nix needs
  ];
}
