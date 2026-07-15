{
  imports = [
    # keep-sorted start
    ./path.nix # set our path
    ./shell.nix # enable our shell integrations
    ./variables.nix # set our environment variables
    ./xdg.nix # set xdg expectations
    # keep-sorted end
  ];
}
