{
  lib,
  config,
  ...
}:
let
  inherit (lib.lists) optional;

  cfg = config.garden.programs.neovim;
in
{
  home.packages = optional cfg.enable cfg.package ++ optional cfg.gui.enable cfg.gui.package;
}
