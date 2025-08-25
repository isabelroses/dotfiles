{
  wayland.windowManager.hyprland.settings.decoration = {
    rounding = 8;
    rounding_power = 4;

    # 0.8 is nice if we opacity
    active_opacity = 1.0;
    inactive_opacity = 1.0;
    fullscreen_opacity = 1.0;

    shadow = {
      enabled = true;
      color = "0x33000000";
      color_inactive = "0x33000000";
    };

    blur = {
      enabled = true;
      passes = 2;
      size = 8;

      brightness = 0.81;
      contrast = 1.3;
      noise = 1.17e-2;
      ignore_opacity = true;

      xray = true;
      special = true;
    };
  };
}
