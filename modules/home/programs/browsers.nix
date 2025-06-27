{ self, pkgs, ... }:
let
  inherit (self.lib) mkProgram;
in
{
  options.garden.programs = {
    chromium = mkProgram pkgs "chromium" { };

    firefox = mkProgram pkgs "firefox" {
      package.default = pkgs.firefox.override {
        speechSynthesisSupport = false;
      };
    };
  };
}
