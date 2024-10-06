{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.validators) isWayland;
  inherit (lib.programs) mkProgram;
in
{
  options.garden.programs = {
    rofi = mkProgram pkgs "rofi" {
      package.default =
        let
          pkg = if isWayland config then pkgs.rofi-wayland else pkgs.rofi;
        in
        pkg.override { plugins = [ pkgs.rofi-rbw ]; };
    };

    wofi = mkProgram pkgs "wofi" { };
  };
}
