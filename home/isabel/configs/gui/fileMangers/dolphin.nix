{
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  config = lib.mkIf osConfig.garden.programs.gui.fileManagers.dolphin.enable {
    home.packages = with pkgs; [ libsForQt5.dolphin ];
  };
}
