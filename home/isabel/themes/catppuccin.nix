{
  pkgs,
  self,
  config,
  inputs,
  osConfig,
  ...
}:
let
  inherit (self.lib.validators) hasProfile;
  nonAccepted = [ "server" ];

  isGui = pkgs.stdenv.hostPlatform.isLinux && config.garden.programs.gui.enable;
in
{
  imports = [ inputs.catppuccin.homeManagerModules.catppuccin ];

  config = {
    catppuccin = {
      enable = !(hasProfile osConfig nonAccepted);
      flavor = "mocha";
      accent = "pink";

      cursors = {
        enable = isGui;
        accent = "dark";
      };

      gtk = {
        enable = isGui;
        icon.enable = isGui;
      };

      # I don't even use the colors from the port
      waybar.enable = false;

      # IFD and can use term colors
      starship.enable = false;

      # IFD and easy enough to vendor
      fzf.enable = false;
    };
  };
}
