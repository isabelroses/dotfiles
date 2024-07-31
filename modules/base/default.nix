{
  imports = [
    ./activation # activation system for nixos-rebuild
    ./environment # basic system environment configuration i.e. shell aliases and environment variables
    ./nix # all nix related configurations
    ./options # options that occur on all systems
    ./programs # programs that are installed system-wide no matter the device
    ./themes # themes for the system
    ./users # users of the machine

    ./gaming.nix # super cool procrastinations related things
    ./secrets.nix # shhh
  ];
}
