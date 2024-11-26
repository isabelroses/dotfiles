{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "float, bitwarden"
      "float, ^(rofi)$"
      "float, ^(pwvucontrol)$"
      "float, ^(nm-connection-editor)$"
      "float, ^(blueberry.py)$"
      "float, ^(Color Picker)$"
      "float, ^(Network)$"
      "float, ^(com.github.Aylur.ags)$"
      "float, ^(xdg-desktop-portal)$"
      "float, ^(xdg-desktop-portal-gnome)$"
      "float, ^(transmission-gtk)$"
      "size 800 600,class:Bitwarden"
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
