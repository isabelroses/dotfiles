{
  imports = [
    ./brew # homebrew the package manager
    ./services # services exclusive to nix-darwin

    ./config.nix # native nix-darwin configuration
    ./non-native.nix # functionality not provided by nix-darwin
    ./security.nix # security settings
  ];
}
