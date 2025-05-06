{
  self,
  pkgs,
  config,
  inputs',
  ...
}:
let
  inherit (self.lib) mkProgram;
in
{
  options.garden.programs = {
    ghostty = mkProgram pkgs "ghostty" {
      enable.default = config.garden.profiles.graphical.enable;
    };

    wezterm = mkProgram pkgs "wezterm" {
      package.default = inputs'.tgirlpkgs.packages.wezterm;
    };
  };
}
