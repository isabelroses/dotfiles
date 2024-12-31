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
    ./direnv.nix
    ./eza.nix
    ./fd.nix
    ./freeze.nix
    ./fzf.nix
    ./goc.nix
    ./hyfetch.nix
    ./ripgrep.nix
    ./starship.nix
    # ./tealdear.nix
    ./zoxide.nix
  ];
}
