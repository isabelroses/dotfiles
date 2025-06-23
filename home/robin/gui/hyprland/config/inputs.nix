{ config, osConfig, ... }:
let
  dev = osConfig.garden.device;
in
{
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = dev.keyboard;
      follow_mouse = 0;
      sensitivity = if dev.keyboard == "us" then 0.2 else 0; # -1.0 - 1.0, 0 means no modification.
      force_no_accel = 1;
      numlock_by_default = true; # numlock enable

      # swap caps lock and escape
      # kb_options = "caps:swapescape";

      touchpad = {
        tap-to-click = true;
        natural_scroll = true;
        disable_while_typing = false; # this is annoying
        scroll_factor = 0.2;
      };
    };

    gestures.workspace_swipe = config.garden.profiles.laptop.enable;

    cursor = {
      no_hardware_cursors = true;
    };
  };
}
