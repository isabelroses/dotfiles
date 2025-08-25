{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "tag bitwarden, title:( - Bitwarden)"
      "tag terminal, class:^(com.mitchellh.ghostty)$"

      "float, tag:bitwarden"
      "float, title:^(rofi)$"
      "float, title:^(pwvucontrol)$"
      "float, title:^(nm-connection-editor)$"
      "float, title:^(blueberry.py)$"
      "float, title:^(Color Picker)$"
      "float, title:^(Network)$"
      "float, title:^(com.github.Aylur.ags)$"
      "float, title:^(xdg-desktop-portal)$"
      "float, title:^(xdg-desktop-portal-gnome)$"
      "float, title:^(transmission-gtk)$"
      "size 800 600,tag:bitwarden"

      "norounding, tag:terminal"
    ];

    windowrulev2 = [
      "float, title:^(Picture-in-Picture)$"
      "float, class:^(Viewnior)$"
      "float, class:^(download)$"

      "workspace 6, title:^(.*(Disc|WebC)ord.*)$"

      # throw sharing indicators away
      "workspace special silent, title:^(Firefox — Sharing Indicator)$"
      "workspace special silent, title:^(.*is sharing (your screen|a window)\.)$"
    ];
  };
}
