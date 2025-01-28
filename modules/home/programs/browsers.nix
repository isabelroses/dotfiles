{
  lib,
  pkgs,
  inputs',
  ...
}:
let
  inherit (lib.programs) mkProgram;
in
{
  options.garden.programs = {
    chromium = mkProgram pkgs "chromium" {
      package.default = inputs'.beapkgs.packages.thorium;
    };

    firefox = mkProgram pkgs "firefox" {
      package.default = pkgs.firefox.override {
        speechSynthesisSupport = false;
      };
    };
  };
}
