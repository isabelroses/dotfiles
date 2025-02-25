{
  self,
  pkgs,
  config,
  inputs',
  ...
}:
let
  inherit (self.lib.programs) mkProgram;
in
{
  options.garden.programs = {
    wezterm = mkProgram pkgs "wezterm" {
      enable.default = config.garden.programs.gui.enable;
      package.default = inputs'.tgirlpkgs.packages.wezterm;
    };

    ghostty = mkProgram pkgs "ghostty" { };
    kitty = mkProgram pkgs "kitty" { };
    alacritty = mkProgram pkgs "alacritty" { };
  };
}
