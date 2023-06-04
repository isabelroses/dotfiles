{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./alacritty.nix
    ./nvim.nix
    ./rofi.nix
    ./thunar.nix
  ]; 
}