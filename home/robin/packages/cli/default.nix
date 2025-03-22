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
    ./eza.nix
    ./fd.nix
    ./freeze.nix
    ./fzf.nix
    ./gh.nix
    ./git.nix
    ./goc.nix
    ./hyfetch.nix
    ./jj.nix
    ./nix-your-shell.nix
    ./ripgrep.nix
    ./starship.nix
    # ./tealdear.nix
    ./typst.nix
    ./zk.nix
    ./zoxide.nix
  ];
}
