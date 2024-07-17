{
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}:
{
  imports = [ inputs.catppuccin.homeManagerModules.catppuccin ];

  config = {
    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "pink";
      pointerCursor = {
        enable = pkgs.stdenv.isLinux;
        accent = "dark";
      };
    };

    # pointer / cursor theming
    home.pointerCursor = lib.modules.mkIf (pkgs.stdenv.isLinux && osConfig.garden.programs.gui.enable) {
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };
  };
}
