{config, ...}: let
  inherit (config.modules) system;
in {
  environment.shellAliases = {
    # nix stuff
    rebuild = "nix-store --verify; sudo nixos-rebuild switch --flake ${system.flakePath}#${system.hostname} --use-remote-sudo";
    deploy = "nixos-rebuild switch --flake ${system.flakePath}#$1 --target-host $1 --use-remote-sudo";
    nixclean = "sudo nix-collect-garbage --delete-older-than 3d && nix-collect-garbage -d";
    nixrepair = "nix-store --verify --check-contents --repair";
  };
}
