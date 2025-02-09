{
  imports = [
    ./environment # environment variables & path
    ./packages
    ./programs

    ./desktop.nix # desktop environment
    ./docs.nix # no more docs
    ./fixes.nix # fixes for weird hm quirks
    ./packages.nix # packages to install
  ];
}
