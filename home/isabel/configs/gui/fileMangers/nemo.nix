{
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  config = lib.mkIf osConfig.modules.programs.gui.fileManagers.nemo.enable {
    home.packages = with pkgs; [
      cinnamon.nemo-with-extensions
      cinnamon.nemo-fileroller
      cinnamon.nemo-emblems
    ];
  };
}
