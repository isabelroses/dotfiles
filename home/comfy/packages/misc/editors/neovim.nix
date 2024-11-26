{
  lib,
  osConfig,
  ...
}:
let
  inherit (lib.lists) optional;

  cfg = osConfig.garden.programs.neovim;
in
{
  home.packages = optional cfg.enable cfg.package ++ optional cfg.gui.enable cfg.gui.package;
}
