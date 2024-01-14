{
  pkgs,
  lib,
  config,
  osConfig,
  inputs',
  ...
}: let
  inherit (osConfig.modules) environment system;
in {
  config = lib.mkIf ((lib.isWayland osConfig) && osConfig.modules.programs.gui.bars.ags.enable) {
    home = {
      packages = with pkgs; [
        inputs'.ags.packages.default
        socat
        sassc
        networkmanagerapplet
        inotify-tools
        swww
        libgtop
        libsoup_3
        gvfs
      ];
    };
    xdg.configFile = let
      symlink = fileName: {recursive ? false}: {
        source = config.lib.file.mkOutOfStoreSymlink "${environment.flakePath}/${fileName}";
        inherit recursive;
      };
    in {
      "ags" = symlink "home/${system.mainUser}/programs/configs/gui/bars/ags/config" {
        recursive = true;
      };
    };
  };
}
