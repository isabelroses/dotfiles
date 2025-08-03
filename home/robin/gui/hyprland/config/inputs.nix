{ config, osConfig, ... }:
let
  dev = osConfig.garden.device;
in
{
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = dev.keyboard;
      follow_mouse = 0;
      sensitivity = 1;
      force_no_accel = 1;
      numlock_by_default = true; # numlock enable
      repeat_rate = 50;
      repeat_delay = 250;

      # caps lock as an additional esc
      # but shift + capslock is the regular capslock
      kb_options = "caps:escape_shifted_capslock";

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
