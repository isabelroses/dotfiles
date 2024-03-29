{
  imports = [
    ./brew # homebrew the package manager
    ./hardware # hardware config - i.e. keyboard
    ./services # services exclusive to nix-darwin

    ./activation.nix # run when we start the system
    ./config.nix # native nix-darwin configuration
    ./non-native.nix # functionality not provided by nix-darwin
    ./security.nix # security settings
    ./nix.nix # nix settings that can only be applied to nix-darwin
  ];
}
