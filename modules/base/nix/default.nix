{
  imports = [
    ./environment.nix # environment settings that nix requires
    ./nix.nix # nix the package manager's settings
    ./plugins.nix # nix plugins
    ./substituters.nix # nixpkgs substituters
  ];
}
