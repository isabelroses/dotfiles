{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf boolToNum;
  inherit (osConfig.garden) device;
  cfg = osConfig.garden.style;

  acceptedTypes = [
    "laptop"
    "desktop"
    "hybrid"
    "lite"
  ];
in
{
  config = mkIf (builtins.elem device.type acceptedTypes && pkgs.stdenv.isLinux) {
    xdg.systemDirs.data =
      let
        schema = pkgs.gsettings-desktop-schemas;
      in
      [ "${schema}/share/gsettings-schemas/${schema.name}" ];

    home = {
      packages = [
        pkgs.glib # gsettings
      ];

      # gtk applications should use xdg specified settings
      sessionVariables.GTK_USE_PORTAL = "${toString (boolToNum cfg.gtk.usePortal)}";
    };

    gtk = {
      enable = true;

      catppuccin = {
        enable = true;
        icon.enable = true;
      };

      font = {
        inherit (cfg.font) name size;
      };

      gtk2 = {
        configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
        extraConfig = ''
          gtk-xft-antialias=1
          gtk-xft-hinting=1
          gtk-xft-hintstyle="hintslight"
          gtk-xft-rgba="rgb"
        '';
      };

      gtk3.extraConfig = {
        # make things look nice
        gtk-application-prefer-dark-theme = true;

        gtk-decoration-layout = "appmenu:none";

        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";

        # stop annoying sounds
        gtk-enable-event-sounds = 0;
        gtk-enable-input-feedback-sounds = 0;
        gtk-error-bell = 0;

        # config that is not the same as gtk4
        gtk-toolbar-style = "GTK_TOOLBAR_BOTH";
        gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";

        gtk-button-images = 1;
        gtk-menu-images = 1;
      };

      gtk4.extraConfig = {
        # make things look nice
        gtk-application-prefer-dark-theme = true;

        gtk-decoration-layout = "appmenu:none";

        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";

        # stop annoying sounds again
        gtk-enable-event-sounds = 0;
        gtk-enable-input-feedback-sounds = 0;
        gtk-error-bell = 0;
      };
    };
  };
}
