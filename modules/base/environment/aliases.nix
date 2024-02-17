{
  environment.shellAliases = {
    nixclean = "sudo nix-collect-garbage --delete-older-than 3d && nix-collect-garbage -d";
    nixrepair = "nix-store --verify --check-contents --repair";
  };
}
