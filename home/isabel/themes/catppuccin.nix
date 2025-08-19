{
  config,
  inputs,
  options,
  osClass,
  ...
}:
let
  isGui = osClass == "nixos" && config.garden.profiles.graphical.enable;
in
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  config = {
    catppuccin = {
      inherit (config.garden.profiles.workstation) enable;
      sources = options.catppuccin.sources.default;

      flavor = "mocha";
      accent = "pink";

      cursors = {
        enable = isGui;
        accent = "dark";
      };

      gtk.icon.enable = isGui;

      # I don't even use the colors from the port
      waybar.enable = false;

      # IFD and can use term colors
      starship.enable = false;

      # IFD and easy enough to vendor
      fzf.enable = false;
    };
  };
}
