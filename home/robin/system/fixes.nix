{
  lib,
  config,
  ...
}:
{
  home.file = lib.modules.mkIf config.garden.programs.gui.enable {
    ".icons/default/index.theme".enable = false;
    ".icons/${config.home.pointerCursor.name}".enable = false;
  };
}
