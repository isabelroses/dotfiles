{
  wayland.windowManager.hyprland.settings.animations = {
    enabled = true;
    first_launch_animation = false;

    # █▄▄ █▀▀ ▀█ █ █▀▀ █▀█   █▀▀ █░█ █▀█ █░█ █▀▀
    # █▄█ ██▄ █▄ █ ██▄ █▀▄   █▄▄ █▄█ █▀▄ ▀▄▀ ██▄
    bezier = [
      "wind, 0.05, 0.9, 0.1, 1.05"
      "winIn, 0.1, 1.1, 0.1, 1.1"
      "winOut, 0.3, -0.3, 0, 1"
      "liner, 1, 1, 1, 1"
      "overshot, 0.05, 0.9, 0.1, 1.05"
      "smoothOut, 0.36, 0, 0.66, -0.56"
      "smoothIn, 0.25, 1, 0.5, 1"
    ];
    # ▄▀█ █▄░█ █ █▀▄▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█
    # █▀█ █░▀█ █ █░▀░█ █▀█ ░█░ █ █▄█ █░▀█
    animation = [
      "windows, 1, 5, overshot, popin"
      "windowsOut, 1, 1, smoothOut, popin"
      "windowsMove, 1, 4, default"
      "border, 1, 10, default"
      "borderangle, 1, 8, default"
      "fade, 1, 10, smoothIn"
      "fadeDim, 1, 10, smoothIn"
      "workspaces, 1, 6, default"
      "specialWorkspace, 1, 6, smoothIn, slidevert"
    ];
  };
}
