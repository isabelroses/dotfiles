{pkgs, ...}: {
  xdg.configFile."kdeglobals".source = "${(pkgs.catppuccin-kde.override {
    flavour = ["mocha"];
    accents = ["sapphire"];
    winDecStyles = ["modern"];
  })}/share/color-schemes/CatppuccinMochasapphire.colors";
  qt = {
    enable = true;
    # platformTheme = "gtk"; # just an override for QT_QPA_PLATFORMTHEME, takes "gtk" or "gnome"
    style = {
      package = pkgs.catppuccin-kde;
      name = "Catpuccin-Mocha-Dark";
    };
  };

  # credits: yavko
  # catppuccin theme for qt-apps
  home.packages = with pkgs; [
    qt5.qttools
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    breeze-icons
  ];

  home.sessionVariables = {
    #QT_QPA_PLATFORMTHEME = "kvantum"; # can't be used alongside kvantum, nix above knows why
    QT_STYLE_OVERRIDE = "kvantum";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    DISABLE_QT5_COMPAT = "0";

    # tell calibre to use the dark theme, because the light one hurts my eyes
    CALIBRE_USE_DARK_PALETTE = "1";
  };

  xdg.configFile."Kvantum/catppuccin/catppuccin.kvconfig".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/Kvantum/main/src/Catppuccin-Mocha-Sapphire/Catppuccin-Mocha-Sapphire.kvconfig";
    sha256 = "0n9f5hysr4k1sf9fd3sgd9fvqwrxrpcvj6vajqmb5c5ji8nv2w3c";
  };

  xdg.configFile."Kvantum/catppuccin/catppuccin.svg".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/Kvantum/main/src/Catppuccin-Mocha-Sapphire/Catppuccin-Mocha-Sapphire.svg";
    sha256 = "1hq9h34178h0d288hgwb0ngqnixz24m9lk0ahc4dahwqn77fndwf";
  };

  /*
  xdg.configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
    General.Theme = "Catppuccin-Mocha-Mauve";
  };
  */

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=catppuccin

    [Applications]
    catppuccin=qt5ct, org.kde.dolphin, org.kde.kalendar, org.qbittorrent.qBittorrent, hyprland-share-picker, dolphin-emu, Nextcloud, nextcloud
  '';
}
