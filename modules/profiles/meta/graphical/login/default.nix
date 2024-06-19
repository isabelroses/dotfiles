{
  imports = [
    ./displaymanager # the login manager

    ./logind.nix # this mainly handles the power management
    ./pam.nix # the authentication manager
  ];
}
