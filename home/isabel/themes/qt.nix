{
  lib,
  pkgs,
  osConfig,
  ...
}: let
  inherit (lib) mkIf optionals;
  inherit (osConfig.modules) device;
  cfg = osConfig.modules.style;

  acceptedTypes = ["laptop" "desktop" "hybrid" "lite"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes && pkgs.stdenv.isLinux) {
    xdg.configFile = {
      "kdeglobals".source = cfg.qt.kdeglobals.source;

      "Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
        General.theme = "catppuccin";
        Applications.catppuccin = ''
          qt5ct, org.kde.dolphin, org.kde.kalendar, org.qbittorrent.qBittorrent, hyprland-share-picker, dolphin-emu, Nextcloud, nextcloud, cantata, org.kde.kid3-qt
        '';
      };

      "Kvantum/catppuccin/catppuccin.kvconfig".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/Kvantum/main/src/Catppuccin-Mocha-Pink/Catppuccin-Mocha-Pink.kvconfig";
        sha256 = "sha256-Lcz2HJddrT6gw9iIB4pTiJMtOeyYU7/u/uoGEv8ykY0=";
      };

      "Kvantum/catppuccin/catppuccin.svg".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/Kvantum/main/src/Catppuccin-Mocha-Pink/Catppuccin-Mocha-Pink.svg";
        sha256 = "sha256-A5lahq0cFuRdp/BwM4/jxDD6Vvut+ZaFYa25KHhqneY=";
      };
    };

    qt = {
      enable = true;
      platformTheme.name = mkIf cfg.forceGtk "gtk3"; # an override for QT_QPA_PLATFORMTHEME
      style = mkIf (!cfg.forceGtk) {
        name = cfg.qt.theme.name;
        package = cfg.qt.theme.package;
      };
    };

    home.packages = with pkgs;
      [
        libsForQt5.qt5ct
        breeze-icons

        # add theme package to path just in case
        cfg.qt.theme.package
      ]
      ++ optionals cfg.useKvantum [
        qt6Packages.qtstyleplugin-kvantum
        libsForQt5.qtstyleplugin-kvantum
      ];

    home.sessionVariables = {
      # scaling - 1 means no scaling
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";

      # use wayland as the default backend, fallback to xcb if wayland is not available
      QT_QPA_PLATFORM = "wayland;xcb";

      # disable window decorations everywhere
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

      # remain backwards compatible with qt5
      DISABLE_QT5_COMPAT = "0";

      # tell calibre to use the dark theme
      CALIBRE_USE_DARK_PALETTE = "1";
    };
  };
}
