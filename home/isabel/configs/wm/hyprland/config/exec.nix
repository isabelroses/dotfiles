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
    exec = [
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=hyprland"
      "systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr"
      "systemctl --user start pipewire wireplumber pipewire-media-session xdg-desktop-portal xdg-desktop-portal-hyprland"
    ];

    exec-once =
      [
        "wl-paste --type text --watch cliphist store" # Stores only text data
        "wl-paste --type image --watch cliphist store" # Stores only image data
        "hyprctl setcursor ${pointer.name} ${toString pointer.size}"
      ]
      ++ optionals (defaults.bar == "waybar") [ "waybar" ] ++ optionals (defaults.bar == "ags") [ "ags" ];
  };
}
