{
  lib,
  config,
  inputs',
  osConfig,
  ...
}:
let
  inherit (osConfig.garden) environment system;
in
{
  config = lib.modules.mkIf osConfig.garden.programs.gui.terminals.wezterm.enable {
    home.packages = [ inputs'.beapkgs.packages.wezterm ];

    xdg.configFile."wezterm" = {
      source = config.lib.file.mkOutOfStoreSymlink "${environment.flakePath}/home/${system.mainUser}/packages/gui/terminals/wezterm";
      recursive = true;
    };
  };
}
