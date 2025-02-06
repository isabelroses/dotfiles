{
  lib,
  self,
  pkgs,
  inputs,
  config,
  osConfig,
  ...
}:
let
  inherit (self.lib.validators) isAcceptedDevice;
  nonAccepted = [
    "server"
    "wsl"
  ];

  en = pkgs.stdenv.hostPlatform.isLinux && config.garden.programs.gui.enable;
in
{
  imports = [ inputs.catppuccin.homeManagerModules.catppuccin ];

  config = {
    catppuccin = {
      enable = !(isAcceptedDevice osConfig nonAccepted);
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
      x11.enable = !(self.lib.validators.isWayland osConfig);
    };
  };
}
