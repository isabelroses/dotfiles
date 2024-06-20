{
  wayland.windowManager.hyprland.settings.group = {
    insert_after_current = true;
    # focus on the window that has just been moved out of the group
    focus_removed_window = true;

    "col.border_active" = "$rosewater";
    "col.border_inactive" = "$surface1";

    groupbar = {
      gradients = false;
      font_size = 12;

      render_titles = false;
      scrolling = true; # change focused window with scroll
    };
  };
}
