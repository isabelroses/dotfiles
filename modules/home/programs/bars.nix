{
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (self.lib.programs) mkProgram;
in
{
  options.garden.programs = {
    ags = mkProgram pkgs "ags" {
      enable.default =
        (config.garden.environment.desktop == "Hyprland") && config.garden.programs.gui.enable;
    };

    waybar = mkProgram pkgs "waybar" { };
  };
}
