{
  self,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (self.lib.validators) isWayland;
  inherit (self.lib.programs) mkProgram;
in
{
  options.garden.programs = {
    rofi = mkProgram pkgs "rofi" {
      package.default =
        let
          pkg = if isWayland osConfig then pkgs.rofi-wayland else pkgs.rofi;
        in
        pkg.override { plugins = [ pkgs.rofi-rbw ]; };
    };

    wofi = mkProgram pkgs "wofi" { };
  };
}
