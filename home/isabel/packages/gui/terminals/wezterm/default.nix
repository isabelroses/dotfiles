{
  lib,
  config,
  osConfig,
  ...
}:
let
  inherit (osConfig.garden) environment system;

  cfg = osConfig.garden.programs.wezterm;
in
{
  config = lib.modules.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."wezterm" = {
      source = config.lib.file.mkOutOfStoreSymlink "${environment.flakePath}/home/${system.mainUser}/packages/gui/terminals/wezterm";
      recursive = true;
    };
  };
}
