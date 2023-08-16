{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types mdDoc;
  cfg = config.modules.style;
in {
  options = {
    modules = {
      style = {
        forceGtk = mkEnableOption "Force GTK applications to use the GTK theme";
        useKvantum = mkEnableOption "Use Kvantum to theme QT applications";

        # choose a colorscheme
        colorScheme = {
          # "Name Of The Scheme"
          name = mkOption {
            type = with types; nullOr (enum ["Catppuccin Mocha" "Tokyo Night"]);
            description = "The colorscheme that should be used globally to theme your system.";
            default = "Catppuccin Mocha";
          };

          # "name-of-the-scheme"
          slug = mkOption {
            type = types.str;
            default = lib.serializeTheme "${cfg.colorScheme.name}";
            description = mdDoc ''
              The serialized slug for the colorScheme you are using. Defaults to a lowercased version of the theme name with spaces
              replaced with hyphens. Only change if the slug is expected to be different."
            '';
          };
        };

        pointerCursor = {
          package = mkOption {
            type = types.package;
            description = "The package providing the cursors";
            default = pkgs.catppuccin-cursors.mochaDark;
          };

          name = mkOption {
            type = types.str;
            description = "The name of the cursor inside the package";
            default = "Catppuccin-Mocha-Dark-Cursors";
          };

          size = mkOption {
            type = types.int;
            description = "The size of the cursor";
            default = 24;
          };
        };

        # qt specific options
        qt = {
          theme = {
            package = mkOption {
              type = types.package;
              default = pkgs.catppuccin-kde.override {
                flavour = ["mocha"];
                accents = ["sapphire"];
                winDecStyles = ["modern"];
              };
              description = "The theme package to be used for QT programs";
            };
            name = mkOption {
              type = types.str;
              default = "Catppuccin-Mocha-Dark";
              description = "The name for the QT theme package";
            };
          };

          kdeglobals.source = mkOption {
            type = types.path;
            default = "${cfg.qt.theme.package}/";
          };
        };

        # gtk specific options
        gtk = {
          usePortal = mkEnableOption "native desktop portal use for filepickers";

          theme = {
            name = mkOption {
              type = types.str;
              default = "Catppuccin-Mocha-Standard-Sapphire-dark";
              description = "The name for the GTK theme package";
            };

            package = mkOption {
              type = types.package;
              description = "The theme package to be used for GTK programs";
              default = pkgs.catppuccin-gtk.override {
                size = "standard";
                accents = ["sapphire"];
                variant = "mocha";
                tweaks = ["normal"];
              };
            };
          };

          iconTheme = {
            name = mkOption {
              type = types.str;
              description = "The name for the icon theme that will be used for GTK programs";

              default = "Papirus-Dark";
            };

            package = mkOption {
              type = types.package;
              description = "The GTK icon theme to be used";
              default = pkgs.catppuccin-papirus-folders.override {
                accent = "sapphire";
                flavor = "mocha";
              };
            };
          };

          font = {
            name = mkOption {
              type = types.str;
              description = "The name of the font that will be used for GTK applications";
              default = "RobotoMono Nerd Font";
            };

            size = mkOption {
              type = types.int;
              description = "The size of the font";
              default = 13;
            };
          };
        };
      };
    };
  };
}
