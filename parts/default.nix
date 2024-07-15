{
  imports = [
    ../systems # the host systems configurations

    ./lib # the lib that is used in the system
    ./modules # nixos and home-manager modules
    ./programs # programs that run in the dev shell
    ./templates # programing templates for the quick setup of new programing environments

    ./args.nix # the base args that is passed to the flake
  ];
}
