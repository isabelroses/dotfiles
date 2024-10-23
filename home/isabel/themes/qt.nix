{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isAcceptedDevice;

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
      style = {
        name = "kvantum";
        # FIXME: remove when 24.11 is released
        catppuccin.enable = false;
      };
    };

    xdg.configFile =
      let
        inherit (config.catppuccin) accent;
        variant = config.catppuccin.flavor;
        theme = pkgs.catppuccin-kvantum.override { inherit accent variant; };
        themeName = "catppuccin-${variant}-${accent}";
      in
      {
        "Kvantum/${themeName}".source = "${theme}/share/Kvantum/${themeName}";
        "Kvantum/kvantum.kvconfig" = {
          text = ''
            [General]
            theme=${themeName}
          '';
        };
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
