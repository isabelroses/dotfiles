{
  imports = [
    # keep-sorted start
    ./path.nix # set our path
    ./shell.nix # enable our shell intergrations
    ./variables.nix # set our environment variables
    ./xdg.nix # set xdg expectations
    # keep-sorted end
  ];
}
