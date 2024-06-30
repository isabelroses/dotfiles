{
  imports = [
    ../hosts # the hosts that are used in the system

    ./lib # the lib that is used in the system
    ./modules # nixos and home-manager modules
    ./overlays # overlays that make the system that bit cleaner
    ./programs # programs that run in the dev shell
    ./templates # programing templates for the quick setup of new programing environments

    ./args.nix # the base args that is passed to the flake
  ];
}
