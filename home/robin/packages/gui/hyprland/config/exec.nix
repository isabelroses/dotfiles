{
  lib,
  config,
  ...
}:
let
  inherit (lib.lists) optionals;

  pointer = config.home.pointerCursor;
  inherit (config.garden.programs) defaults;
in
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "wl-paste --type text --watch cliphist store" # Stores only text data
      "wl-paste --type image --watch cliphist store" # Stores only image data
      "hyprctl setcursor ${pointer.name} ${toString pointer.size}"
      "swww-daemon"
    ] ++ optionals (defaults.bar == "waybar") [ "waybar" ];
  };
}
