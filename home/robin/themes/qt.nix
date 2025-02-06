{
  lib,
  self,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) isAcceptedDevice;

  acceptedTypes = [
    "laptop"
    "desktop"
    "hybrid"
    "lite"
  ];
in
{
  config = mkIf (isAcceptedDevice osConfig acceptedTypes && pkgs.stdenv.hostPlatform.isLinux) {
    qt = {
      enable = true;
      platformTheme.name = "kvantum";
      style.name = "kvantum";
    };

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
