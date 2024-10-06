{
  lib,
  pkgs,
  config,
  inputs',
  ...
}:
let
  inherit (lib.options) mkPackageOption mkEnableOption;
  inherit (lib.programs) mkProgram;
in
{
  options.garden.programs = {
    wezterm = mkProgram pkgs "wezterm" {
      enable.default = config.garden.programs.gui.enable;
      package.default = inputs'.beapkgs.packages.wezterm;
    };

    # ghosty errors if we use mkProgram since the package is not in the nixpkgs
    ghostty = {
      enable = mkEnableOption "ghostty";
      package = mkPackageOption inputs'.ghostty.packages "ghostty" { };
    };

    kitty = mkProgram pkgs "kitty" { };
    alacritty = mkProgram pkgs "alacritty" { };
  };
}
