{ lib, config, ... }:
{
  config = {
    programs.wezterm.enable = lib.mkDefault (
      config.garden.profiles.graphical.enable && config.garden.programs.defaults.terminal == "wezterm"
    );

    xdg.configFile."wezterm" = lib.mkIf config.programs.wezterm.enable {
      source = ./cfg;
      recursive = true;
    };
  };
}
