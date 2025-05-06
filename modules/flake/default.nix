{
  imports = [
    ../../systems

    ./checks # custom checks that are devised to test if the system is working as expected
    ./lib # the lib that is used in the system
    ./packages # our custom packages provided by the flake
    ./programs # programs that run in the dev shell

    ./args.nix # the base args that is passed to the flake
  ];
}
