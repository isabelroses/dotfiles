{osConfig, ...}: let
  inherit (osConfig.modules) system;
in {
  # This configuration creates the shell aliases across: bash, zsh and fish
  home.shellAliases = {
    mkdir = "mkdir -pv"; # always create pearent directory
    df = "df -h"; # human readblity
    rs = "sudo reboot";
    sysctl = "sudo systemctl";
    jctl = "journalctl -p 3 -xb"; # get error messages from journalctl
    lg = "lazygit";

    # Remap docker to podman
    docker = "podman";
    docker-compose = "podman-compose";

    # nix stuff
    rebuild = "nix-store --verify; sudo nixos-rebuild switch --flake ${system.flakePath}#${system.hostname} --use-remote-sudo";
    deploy = "nixos-rebuild switch --flake ${system.flakePath}#$1 --target-host $1 --use-remote-sudo -Lv";
    nixclean = "sudo nix-collect-garbage --delete-older-than 3d && nix-collect-garbage -d";
    nixrepair = "nix-store --verify --check-contents --repair";
  };
}
