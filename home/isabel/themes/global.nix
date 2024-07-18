{
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}:
let
  en = pkgs.stdenv.isLinux && osConfig.garden.programs.gui.enable;
in
{
  imports = [ inputs.catppuccin.homeManagerModules.catppuccin ];

  config = {
    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "pink";

      pointerCursor = {
        enable = en;
        accent = "dark";
      };
    };

    # pointer / cursor theming
    home.pointerCursor = lib.modules.mkIf en {
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };
  };
}
