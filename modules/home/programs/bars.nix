{
  lib,
  pkgs,
  config,
  inputs',
  osConfig,
  ...
}:
let
  inherit (lib.programs) mkProgram;
in
{
  options.garden.programs = {
    ags = mkProgram pkgs "ags" {
      enable.default =
        (osConfig.garden.environment.desktop == "Hyprland") && config.garden.programs.gui.enable;
      package.default = inputs'.ags.packages.ags;
    };

    waybar = mkProgram pkgs "waybar" { };
  };
}
