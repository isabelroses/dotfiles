{
  imports = [
    ./logind.nix # this mainly handles the power management
    ./pam.nix # the authentication manager

    # our login managers
    ./options.nix
    ./cosmic-greeter.nix
    ./greetd.nix
    ./sddm.nix
  ];
}
