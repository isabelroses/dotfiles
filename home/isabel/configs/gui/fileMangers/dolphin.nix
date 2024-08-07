{
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  config = lib.modules.mkIf osConfig.garden.programs.gui.fileManagers.dolphin.enable {
    home.packages = [ pkgs.kdePackages.dolphin ];
  };
}
