{
  lib,
  config,
  ...
}:
let
  inherit (lib) optional;

  cfg = config.garden.programs.neovim;
in
{
  home.packages = optional cfg.enable cfg.package ++ optional cfg.gui.enable cfg.gui.package;
}
