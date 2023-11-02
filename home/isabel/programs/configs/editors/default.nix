{pkgs, ...}: {
  imports = [
    ./micro
    ./nvim # https://github.com/NotAShelf/neovim-flake/
    ./vscode
  ];
  config.home.packages = with pkgs; [
    arduino # need this one for uni
  ];
}
