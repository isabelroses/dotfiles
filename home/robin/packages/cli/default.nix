{
  imports = [
    # package list
    ./shared.nix
    ./desktop.nix
    ./wayland.nix

    # configs
    ./shell # shell configurations

    ./atuin.nix
    ./bat.nix
    # ./bellado.nix
    ./eza.nix
    ./fd.nix
    ./freeze.nix
    ./fzf.nix
    ./goc.nix
    ./hyfetch.nix
    ./nix-your-shell.nix
    ./ripgrep.nix
    ./starship.nix
    # ./tealdear.nix
    ./zk.nix
    ./zoxide.nix
  ];
}
