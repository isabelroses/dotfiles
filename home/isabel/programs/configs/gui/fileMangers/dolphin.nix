{
  osConfig,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf osConfig.modules.programs.fileManagers.dolphin.enable {
    home.packages = with pkgs; [
      libsForQt5.dolphin
    ];
  };
}
