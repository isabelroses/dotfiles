{
  lib,
  config,
  ...
}:
let
  cfg = config.garden.programs.wezterm;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."wezterm" = {
      source = ./wezterm;
      recursive = true;
    };
  };
}
