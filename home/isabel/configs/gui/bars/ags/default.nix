{
  lib,
  pkgs,
  inputs',
  config,
  osConfig,
  ...
}:
let
  inherit (osConfig.garden) environment system programs;
in
{
  # TODO: package this
  config = lib.mkIf ((lib.isWayland osConfig) && programs.gui.bars.ags.enable) {
    home = {
      packages =
        [ inputs'.ags.packages.ags ]
        ++ (with pkgs; [
          bun
          dart-sass
          brightnessctl
          hyprpicker
        ]);
    };

    xdg.configFile."ags" = {
      source = config.lib.file.mkOutOfStoreSymlink "${environment.flakePath}/home/${system.mainUser}/configs/gui/bars/ags";
      recursive = true;
    };
  };
}
