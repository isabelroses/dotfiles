{
  imports = [
    ./programs

    ./desktop.nix # desktop environment
    ./docs.nix # no more docs
    ./env.nix # environment variables
    ./fixes.nix # fixes for weird hm quirks
    ./packages.nix # packages to install
  ];
}
