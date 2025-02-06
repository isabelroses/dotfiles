{
  lib,
  pkgs,
  self,
  config,
  osConfig,
  ...
}:
let
  en = pkgs.stdenv.hostPlatform.isLinux && config.garden.programs.gui.enable;
in
{
  # pointer / cursor theming
  config.home.pointerCursor = lib.modules.mkIf en {
    name = "Capitaine Cursors";
    package = pkgs.capitaine-cursors-themed;
    size = 24;
    gtk.enable = true;
    # this adds extra deps, so lets only enable it on wayland
    x11.enable = !(self.lib.validators.isWayland osConfig);
  };
}
