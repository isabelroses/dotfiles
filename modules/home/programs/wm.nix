{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (self.lib) mkProgram;
in
{
  options.garden.programs = {
    hyprland = mkProgram pkgs "hyprland" {
      enable.default = config.garden.profiles.graphical.enable;
    };

    fht-compositor.enable = lib.mkEnableOption "fht-compositor";
  };
}
