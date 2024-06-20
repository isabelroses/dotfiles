{ osConfig, ... }:
let
  dev = osConfig.modules.device;
in
{
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = dev.keyboard;
      follow_mouse = 1;
      sensitivity = -1.0; # -1.0 - 1.0, 0 means no modification.
      numlock_by_default = true; # numlock enable

      # swap caps lock and escape
      kb_options = "caps:swapescape";

      touchpad = {
        tap-to-click = true;
        natural_scroll = false; # this is not natural
        disable_while_typing = false; # this is annoying
      };
    };

    gestures.workspace_swipe = dev.type == "laptop" || dev.type == "hybrid";

    cursor = {
      no_hardware_cursors = true;
    };
  };
}
