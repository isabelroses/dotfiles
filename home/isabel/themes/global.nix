{osConfig, ...}: let
  cfg = osConfig.modules.style;
in {
  # pointer / cursor theming
  home.pointerCursor = {
    name = cfg.pointerCursor.name;
    package = cfg.pointerCursor.package;
    size = cfg.pointerCursor.size;
    gtk.enable = true;
    x11.enable = true;
  };
}
