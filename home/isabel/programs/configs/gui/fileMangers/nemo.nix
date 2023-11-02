{
  osConfig,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf osConfig.modules.programs.fileManagers.nemo.enable {
    home.packages = with pkgs; [
      cinnamon.nemo-with-extensions
      cinnamon.nemo-fileroller
      cinnamon.nemo-emblems
    ];
  };
}
