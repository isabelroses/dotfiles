{
  imports = [
    ./gpg.nix # gpg-agent
    ./path.nix # set our path
    ./variables.nix # set our environment variables
    ./xdg.nix # set xdg expectations
  ];
}
