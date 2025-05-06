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
    waybar = mkProgram pkgs "waybar" { };
  };
}
