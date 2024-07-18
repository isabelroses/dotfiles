{
  lib,
  config,
  osConfig,
  ...
}:
{
  home.file = lib.modules.mkIf osConfig.garden.programs.gui.enable {
    ".icons/default/index.theme".enable = false;
    ".icons/${config.home.pointerCursor.name}".enable = false;
  };
}
