{
  wayland.windowManager.hyprland.settings.decoration = {
    rounding = 15;

    # 0.8 is nice if we opacity
    active_opacity = 1.0;
    inactive_opacity = 1.0;
    fullscreen_opacity = 1.0;

    drop_shadow = true;
    "col.shadow" = "rgb(11111B)";
    "col.shadow_inactive" = "rgba(11111B00)";

    blur = {
      enabled = true;
      passes = 2;
      size = 2;

      brightness = 1;
      contrast = 1.3;
      noise = 1.17e-2;
      ignore_opacity = true;

      new_optimizations = true;
      xray = true;
    };
  };
}
