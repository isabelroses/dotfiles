{inputs', ...}: {
  home.packages = [
    inputs'.neovim.packages.default
  ];
}
