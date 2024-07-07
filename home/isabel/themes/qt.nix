{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (osConfig.garden) device;

  acceptedTypes = [
    "laptop"
    "desktop"
    "hybrid"
    "lite"
  ];
in
{
  config = mkIf (builtins.elem device.type acceptedTypes && pkgs.stdenv.isLinux) {
    qt = {
      enable = true;
      platformTheme.name = "kvantum";
      style.name = "kvantum";
    };

    home.packages = with pkgs; [
      kdePackages.qt6ct
      kdePackages.breeze-icons
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
