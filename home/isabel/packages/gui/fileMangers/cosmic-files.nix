{
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  config = lib.modules.mkIf osConfig.garden.programs.gui.fileManagers.cosmic-files.enable {
    home.packages = [ pkgs.cosmic-files ];
  };
}
