{
  wayland.windowManager.hyprland.settings.decoration = {
    rounding = 15;

    # TODO: play with these values
    active_opacity = 0.8;
    inactive_opacity = 0.8;
    fullscreen_opacity = 1.0;

    drop_shadow = true;
    "col.shadow" = "rgb(11111B)";
    "col.shadow_inactive" = "rgba(11111B00)";

    blur = {
      enabled = true;
      passes = 4;
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
