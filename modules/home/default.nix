{
  imports = [
    ./environment # environment variables & path
    ./packages
    ./programs
    ./desktop.nix # desktop environment
    ./docs.nix # no more docs
    ./home.nix # home settings
    ./packages.nix # packages to install
    ./remote-modules.nix # modules that are not in this repo, and don't have a nice place to be imported in
  ];
}
