{
  _class = "homeManager";

  imports = [
    # keep-sorted start
    ../generic
    ./docs.nix # no more docs
    ./environment # environment variables & path
    ./extras.nix # modules that are not in this repo, and don't have a nice place to be imported in
    ./home.nix # home settings
    ./profiles.nix # profiles for different machines
    ./programs # ways to configure packages
    ./secrets.nix # secrets for the home directory
    ./themes # themes for applications
    # keep-sorted end
  ];
}
