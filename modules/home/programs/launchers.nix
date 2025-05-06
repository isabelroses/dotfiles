{
  self,
  pkgs,
  ...
}:
let
  inherit (self.lib) mkProgram;
in
{
  options.garden.programs = {
    rofi = mkProgram pkgs "rofi" {
      package.default = pkgs.rofi-wayland.override { plugins = [ pkgs.rofi-rbw ]; };
    };

    wofi = mkProgram pkgs "wofi" { };
  };
}
