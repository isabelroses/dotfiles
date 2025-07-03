{ lib, config, ... }:
{
  config = lib.mkIf config.programs.wezterm.enable {
    catppuccin.wezterm.enable = false;

    xdg.configFile."wezterm" = {
      source = ./wezterm;
      recursive = true;
    };
  };
}
