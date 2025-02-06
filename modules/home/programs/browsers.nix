{
  self,
  pkgs,
  inputs',
  ...
}:
let
  inherit (self.lib.programs) mkProgram;
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
