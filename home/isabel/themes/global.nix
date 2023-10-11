{osConfig, ...}: let
  cfg = osConfig.modules.style;
in {
  # pointer / cursor theming
  home.pointerCursor = {
    package = cfg.pointerCursor.package;
    name = "${cfg.pointerCursor.name}";
    size = cfg.pointerCursor.size;
    gtk.enable = true;
    x11.enable = true;
  };
}
