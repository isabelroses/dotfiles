{
  pkgs,
  lib,
  osConfig,
  ...
}: let
  inherit (lib) mkIf optionals;
  inherit (osConfig.modules) device;
  sys = osConfig.modules.system;
  cfg = osConfig.modules.style;

  acceptedTypes = ["laptop" "desktop" "hybrid" "lite"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes && sys.video.enable) {
    xdg.configFile = {
      "kdeglobals".source = cfg.qt.kdeglobals.source;

      "Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
        General.theme = "catppuccin";
        Applications.catppuccin = ''
          qt5ct, org.kde.dolphin, org.kde.kalendar, org.qbittorrent.qBittorrent, hyprland-share-picker, dolphin-emu, Nextcloud, nextcloud, cantata, org.kde.kid3-qt
        '';
      };

      "Kvantum/catppuccin/catppuccin.kvconfig".source = builtins.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/Kvantum/main/src/Catppuccin-Mocha-Sapphire/Catppuccin-Mocha-Sapphire.kvconfig";
        sha256 = "0n9f5hysr4k1sf9fd3sgd9fvqwrxrpcvj6vajqmb5c5ji8nv2w3c";
      };

      "Kvantum/catppuccin/catppuccin.svg".source = builtins.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/Kvantum/main/src/Catppuccin-Mocha-Sapphire/Catppuccin-Mocha-Sapphire.svg";
        sha256 = "1hq9h34178h0d288hgwb0ngqnixz24m9lk0ahc4dahwqn77fndwf";
      };
    };

    qt = {
      enable = true;
      platformTheme = mkIf cfg.forceGtk "gtk"; # just an override for QT_QPA_PLATFORMTHEME, takes “gtk”, “gnome”, “qtct” or “kde”
      style = mkIf (!cfg.forceGtk) {
        name = "${cfg.qt.theme.name}";
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
