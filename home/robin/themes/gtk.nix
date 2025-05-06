{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf;

  schema = pkgs.gsettings-desktop-schemas;

  cfg = config.garden.style;
in
{
  config = mkIf (config.garden.profiles.graphical.enable && pkgs.stdenv.hostPlatform.isLinux) {
    xdg.systemDirs.data = [ "${schema}/share/gsettings-schemas/${schema.name}" ];

    garden.packages = {
      inherit (pkgs) glib; # gsettings
    };

    home = {
      # gtk applications should use xdg specified settings
      sessionVariables.GTK_USE_PORTAL = "1";
    };

    gtk = {
      enable = true;

      font = {
        inherit (cfg.fonts) name size;
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
