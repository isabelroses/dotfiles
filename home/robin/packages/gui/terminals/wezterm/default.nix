{
  lib,
  osConfig,
  ...
}:
let
  cfg = osConfig.garden.programs.wezterm;
in
{
  config = lib.modules.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."wezterm" = {
      source = ./.;
      recursive = true;
    };
  };
}
