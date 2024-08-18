{
  imports = [
    ./display # display protocol
    ./login # programs to be loaded at login/startup
    ./programs # system programs and more
    ./security # security programs and configurations
    ./services # services that enable better system management

    ./flatpak.nix # flatpak application
    ./xserver.nix # extension of display manager but for only xserver
  ];
}
