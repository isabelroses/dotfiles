{
  osConfig,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf osConfig.modules.programs.fileManager.dolphin.enable {
    home.packages = with pkgs; [
      libsForQt5.dolphin
    ];
  };
}
