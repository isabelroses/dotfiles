{
  imports = [
    ./brew # homebrew the package manager
    ./hardware # hardware config - i.e. keyboard
    ./prefrences # system preferences
    ./security # security settings to keep the system secure
    ./services # services exclusive to nix-darwin

    ./activation.nix # run when we start the system
    ./nix.nix # nix settings that can only be applied to nix-darwin
  ];
}
