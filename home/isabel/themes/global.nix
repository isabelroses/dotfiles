{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  lx = pkgs.stdenv.isLinux;
in
{
  imports = [ inputs.catppuccin.homeManagerModules.catppuccin ];

  config = {
    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "pink";

      # we cannot use this one darwin, so we enable it only on linux
      pointerCursor = {
        enable = lx;
        accent = "dark";
      };
    };

    # pointer / cursor theming
    home.pointerCursor = lib.mkIf lx {
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };
  };
}
