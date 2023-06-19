{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.bat = {
    enable = true;
    catppuccin.enable = true;
  };
}
