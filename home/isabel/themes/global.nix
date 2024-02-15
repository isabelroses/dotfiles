{
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}: let
  cfg = osConfig.modules.style;
in {
  imports = [inputs.catppuccin.homeManagerModules.catppuccin];

  config = {
    catppuccin = {
      flavour = "mocha";
      accent = "sapphire";
    };

    # pointer / cursor theming
    home.pointerCursor = lib.mkIf pkgs.stdenv.isLinux {
      inherit (cfg.pointerCursor) name package size;
      gtk.enable = true;
      x11.enable = true;
    };
  };
}
