{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./flatpak

    ./cli.nix
    ./gui.nix
  ];
}
