{
  wayland.windowManager.hyprland.settings.misc = {
    disable_hyprland_logo = true;
    disable_splash_rendering = true;
    force_default_wallpaper = 0;

    # window swallowing
    enable_swallow = true; # hide windows that spawn other windows
    swallow_regex = "wezterm|foot|cosmic-files|thunar|nemo";

    # dpms
    mouse_move_enables_dpms = true; # enable dpms on mouse/touchpad action
    key_press_enables_dpms = true; # enable dpms on keyboard action
    disable_autoreload = true; # autoreload is unnecessary on nixos, because the config is readonly anyway
  };
}
