{
  imports = [
    # keep-sorted start
    ./gpg.nix # gpg-agent
    ./path.nix # set our path
    ./shell.nix # enable our shell intergrations
    ./variables.nix # set our environment variables
    ./xdg.nix # set xdg expectations
    # keep-sorted end
  ];
}
