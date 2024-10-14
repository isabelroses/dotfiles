{
  lib,
  pkgs,
  inputs',
  osConfig,
  ...
}:
let
  cfg = osConfig.garden.programs.neovim;
in
{
  home.packages = lib.lists.optionals cfg.enable [
    inputs'.izvim.packages.default
    pkgs.neovide
  ];

  xdg.configFile."neovide/config.toml".text = ''
    frame = none
    title-hidden = true
  '';
}
