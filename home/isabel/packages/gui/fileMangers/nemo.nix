{
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  config = lib.modules.mkIf osConfig.garden.programs.gui.fileManagers.nemo.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs.cinnamon) nemo-with-extensions nemo-fileroller nemo-emblems;
    };
  };
}
