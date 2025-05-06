{
  imports = [
    ./environment.nix # environment settings that nix requires
    ./nh.nix # a nix helper cli
    ./nix.nix # nix the package manager's settings
    ./substituters.nix # nixpkgs substituters
  ];
}
