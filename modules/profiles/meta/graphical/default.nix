{
  imports = [
    ./login # programs to be loaded at login/startup
    ./programs # system programs and more
    ./security # security programs and configurations
    ./services # services that enable better system management

    ./display.nix # display manager and window manager
    ./flatpak.nix # flatpak application
    ./xserver.nix # extension of display manager but for only xserver
  ];
}
