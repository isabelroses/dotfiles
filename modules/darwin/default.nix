{
  _class = "darwin";

  imports = [
    # keep-sorted start
    ../base
    ./brew # homebrew the package manager
    ./config-path.nix # set the path to the darwin configuration
    ./documentation.nix # turn off docs
    ./extras.nix # modules that are not in this repo, and don't have a nice place to be imported in
    ./hardware # hardware config - i.e. keyboard
    ./legacy.nix # some shims to keep compatibility with some options that need refactoring upstream
    ./nix.nix # nix settings
    ./preferences # system preferences
    ./security # security settings to keep the system secure
    ./system-packages.nix # system packages will be needed for all users
    # keep-sorted end
  ];
}
