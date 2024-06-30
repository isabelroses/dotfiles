{
  lib,
  config,
  defaults,
  ...
}:
let
  inherit (lib.lists) optionals;

  pointer = config.home.pointerCursor;
in
{
  wayland.windowManager.hyprland.settings = {
    exec-once =
      [
        "wl-paste --type text --watch cliphist store" # Stores only text data
        "wl-paste --type image --watch cliphist store" # Stores only image data
        "hyprctl setcursor ${pointer.name} ${toString pointer.size}"
      ]
      ++ optionals (defaults.bar == "waybar") [ "waybar" ] ++ optionals (defaults.bar == "ags") [ "ags" ];
  };
}
