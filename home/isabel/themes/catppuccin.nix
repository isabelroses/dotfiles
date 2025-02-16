{
  pkgs,
  self,
  config,
  inputs,
  osConfig,
  ...
}:
let
  inherit (self.lib.validators) isAcceptedDevice;
  nonAccepted = [
    "server"
    "wsl"
  ];
in
{
  imports = [ inputs.catppuccin.homeManagerModules.catppuccin ];

  config = {
    catppuccin = {
      enable = !(isAcceptedDevice osConfig nonAccepted);
      flavor = "mocha";
      accent = "pink";

      cursors = {
        enable = pkgs.stdenv.hostPlatform.isLinux && config.garden.programs.gui.enable;
        accent = "dark";
      };

      gtk = {
        enable = true;
        icon.enable = true;
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
