{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./eww.nix
    ./sops.nix
    ./xdgs.nix
  ]; 
}