{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.lazygit = {
    enable = true;
    catppuccin.enable = true;
  };
}
