{
  lib,
  pkgs,
  config,
  inputs',
  ...
}:
let
  inherit (lib.programs) mkProgram;
in
{
  options.garden.programs = {
    ags.enable = mkProgram pkgs "ags" {
      enable.default = config.garden.programs.gui.enable;
      package.default = inputs'.ags.packages.ags;
    };

    waybar = mkProgram pkgs "waybar" { };
  };
}
