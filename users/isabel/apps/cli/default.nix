{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./bat.nix
    ./btop.nix
    ./fish.nix
    ./git.nix
    ./neofetch.nix
    ./starship.nix
  ]; 
}