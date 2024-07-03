{
  lib,
  pkgs,
  inputs',
  config,
  osConfig,
  ...
}:
let
  inherit (osConfig.garden) environment system;
in
{
  config = lib.mkIf ((lib.isWayland osConfig) && osConfig.garden.programs.gui.bars.ags.enable) {
    home = {
      packages =
        [ inputs'.ags.packages.ags ]
        ++ (with pkgs; [
          socat
          sassc
          inotify-tools
          swww
          libgtop
          libsoup_3
          gvfs
        ]);
    };

    xdg.configFile =
      let
        symlink = fileName: {
          source = config.lib.file.mkOutOfStoreSymlink "${environment.flakePath}/${fileName}";
          recursive = true;
        };
      in
      {
        "ags" = symlink "home/${system.mainUser}/configs/gui/bars/ags";
      };
  };
}
