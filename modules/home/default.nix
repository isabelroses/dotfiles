{
  imports = [
    ../generic

    ./environment # environment variables & path
    ./programs # ways to configure packages
    ./themes # themes for applications
    ./docs.nix # no more docs
    ./extras.nix # modules that are not in this repo, and don't have a nice place to be imported in
    ./home.nix # home settings
    ./profiles.nix # profiles for different machines
    ./secrets.nix # secrets for the home directory
  ];
}
