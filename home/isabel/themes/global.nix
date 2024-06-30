{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.catppuccin.homeManagerModules.catppuccin ];

  config = {
    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "pink";
      pointerCursor.accent = "dark";
    };

    # pointer / cursor theming
    home.pointerCursor = lib.mkIf pkgs.stdenv.isLinux {
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };
  };
}
