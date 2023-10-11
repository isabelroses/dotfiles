{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  inherit (lib) mkIf;
  inherit (osConfig.modules) device;
  cfg = osConfig.modules.style;
  sys = osConfig.modules.system;

  acceptedTypes = ["laptop" "desktop" "hybrid" "lite"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes && sys.video.enable) {
    xdg.systemDirs.data = let
      schema = pkgs.gsettings-desktop-schemas;
    in ["${schema}/share/gsettings-schemas/${schema.name}"];

    home = {
      packages = with pkgs; [
        glib # gsettings
        cfg.gtk.theme.package
        cfg.gtk.iconTheme.package
      ];

      sessionVariables = {
        # set GTK theme to the name specified by the gtk package
        GTK_THEME = "${cfg.gtk.theme.name}";

        # gtk applications should use xdg specified settings
        GTK_USE_PORTAL = "${with lib; toString (boolToNum cfg.gtk.usePortal)}";
      };
    };

    gtk = {
      enable = true;

      theme = {
        name = "${cfg.gtk.theme.name}";
        package = cfg.gtk.theme.package;
      };

      iconTheme = {
        name = "${cfg.gtk.iconTheme.name}";
        package = cfg.gtk.iconTheme.package;
      };

      font = {
        name = "${cfg.gtk.font.name}";
        size = cfg.gtk.font.size;
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
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "rgb";
        gtk-application-prefer-dark-theme = 1;
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
  };
}
