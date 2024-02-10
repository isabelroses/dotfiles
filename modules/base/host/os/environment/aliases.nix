{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (config.modules) system environment;
in {
  environment.shellAliases = {
    rebuild =
      lib.ldTernary pkgs
      "nix-store --verify; sudo nixos-rebuild switch --flake ${environment.flakePath}#${system.hostname}"
      "nix-store --verify; darwin-rebuild switch --flake ${environment.flakePath}#${system.hostname}";
    nixclean = "sudo nix-collect-garbage --delete-older-than 3d && nix-collect-garbage -d";
    nixrepair = "nix-store --verify --check-contents --repair";
  };
}
