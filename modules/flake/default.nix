{
  imports = [
    ../../systems # the host systems configurations

    ./checks # custom checks that are devised to test if the system is working as expected
    ./lib # the lib that is used in the system
    ./modules.nix # nixos and home-manager modules
    ./overlays.nix # nixpkgs overlays for custom packages and patches
    ./packages # our custom packages provided by the flake
    ./programs # programs that run in the dev shell

    ./args.nix # the base args that is passed to the flake
  ];
}
