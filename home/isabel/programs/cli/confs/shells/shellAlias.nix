{osConfig, ...}: let
  inherit (osConfig.modules) system;
in {
  home.shellAliases = {
    mkdir = "mkdir -pv"; # always create pearent directory
    df = "df -h"; # human readblity
    rs = "sudo reboot";
    sysctl = "sudo systemctl";
    doas = "doas --";
    jctl = "journalctl -p 3 -xb"; # get error messages from journalctl
    lg = "lazygit";

    # Remap docker to podman
    docker = "podman";
    docker-compose = "podman-compose";

    # nix stuff
    rebuild = "sudo nixos-rebuild switch --flake ${system.flakePath}#${system.hostname}";
    nixclean = "sudo nix-collect-garbage --delete-older-than 3d && nix-collect-garbage -d";
    nixrepair = "nix-store --verify --check-contents --repair";
  };
}
