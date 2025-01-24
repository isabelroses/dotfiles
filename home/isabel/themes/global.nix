{
  lib,
  pkgs,
  inputs,
  config,
  osConfig,
  ...
}:
let
  en = pkgs.stdenv.hostPlatform.isLinux && config.garden.programs.gui.enable;
in
{
  imports = [ inputs.catppuccin.homeManagerModules.catppuccin ];

  config = {
    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "pink";

      cursors = {
        enable = en;
        accent = "dark";
      };

      gtk = {
        enable = true;
        icon.enable = true;
      };

      # I want to disable some
      waybar.enable = false;
    };

    # pointer / cursor theming
    home.pointerCursor = lib.modules.mkIf en {
      size = 24;
      gtk.enable = true;
      # this adds extra deps, so lets only enable it on wayland
      x11.enable = !(lib.validators.isWayland osConfig);
    };
  };
}
