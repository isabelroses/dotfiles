{
  config,
  inputs,
  osClass,
  osConfig,
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
      autoEnable = true;

      flavor = "mocha";
      accent = "pink";

      sources = osConfig.catppuccin.sources;

      cursors = {
        enable = isGui;
        accent = "dark";
      };

      gtk.icon.enable = isGui;

      # IFD and can use term colors
      starship.enable = false;

      # IFD and can use term colors
      eza.enable = false;

      # i don't really like the theme here
      mpv.enable = false;
    };
  };
}
