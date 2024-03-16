{
  imports = [
    ./modules # nixos and home-manager modules
    ./overlays # overlays that make the system that bit cleaner
    ./pkgs # packages exposed to the flake
    ./programs # programs that run in the dev shell
    ./schemas # nix schemas. whenever they actually work
    ./templates # programing templates for the quick setup of new programing enviorments

    ./base.nix # the base args that is passsed to the flake, moved away from the main file
  ];
}
