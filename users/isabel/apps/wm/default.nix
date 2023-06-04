{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hyprland.nix
    ./swaylock.nix
  ]; 
}