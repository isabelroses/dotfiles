{
  _class = "darwin";

  imports = [
    ../base

    ./brew # homebrew the package manager
    ./hardware # hardware config - i.e. keyboard
    ./preferences # system preferences
    ./security # security settings to keep the system secure

    ./config-path.nix # set the path to the darwin configuration
    ./documentation.nix # turn off docs
    ./legacy.nix # some shims to keep compatibility with some options that need refactoring upstream
    ./extra.nix # modules that are not in this repo, and don't have a nice place to be imported in
    ./system-packages.nix # system packages will be needed for all users
    ./nix.nix # nix settings
  ];
}
