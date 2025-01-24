{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.programs) mkProgram;
in
{
  options.garden.programs = {
    cosmic-files = mkProgram pkgs "cosmic-files" {
      enable.default = config.garden.programs.gui.enable;
    };

    dolphin = mkProgram pkgs "dolphin" {
      package.default = pkgs.kdePackages.dolphin;
    };

    nemo = mkProgram pkgs "nemo" {
      package.default = pkgs.nemo-with-extensions;
    };

    thunar = mkProgram pkgs "thunar" { };
  };
}
