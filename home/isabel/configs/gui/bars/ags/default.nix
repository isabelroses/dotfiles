{
  lib,
  pkgs,
  inputs',
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isWayland;

  inherit (osConfig.garden) environment system programs;
in
{
  # TODO: package this
  config = mkIf (isWayland osConfig && programs.gui.bars.ags.enable) {
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
