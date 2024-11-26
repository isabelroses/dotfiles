{
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}:
let
  en = pkgs.stdenv.hostPlatform.isLinux && osConfig.garden.programs.gui.enable;
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
      # this adds extra deps, so lets only enable it on wayland
      x11.enable = !(lib.validators.isWayland osConfig);
    };
  };
}
