{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
in {
  options = {
    profiles = {
      # style module that provides a color profile
      style = {
        colorScheme = {
          name = mkOption {
            type = types.str;
            description = "The colorscheme that should be used globally to theme your system.";
            default = "Catppuccin Mocha";
          };

          slug = mkOption {
            type = types.str;
            description = ''The serialized slug for the colorScheme you are using. For "Catppuccin Mocha", it would be "catppuccin-mocha"'';
            default = "catppuccin-mocha";
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

        qt = {
          style = {
            package = mkOption {
              type = types.package;
              default = pkgs.catppucin-kde;
              description = "The theme package to be used for QT programs";
            };
            name = mkOption {
              type = types.str;
              default = "Catppuccin-Mocha-Dark";
              description = "The name for the QT theme package";
            };
          };
        };

        gtk = {
          usePortal = mkEnableOption "" // {default = true;};
          theme = {
            name = mkOption {
              type = types.str;
              default = "Catppuccin-Mocha-Compact-Sapphire-Dark";
              description = "The name for the GTK theme package";
            };
            package = mkOption {
              type = types.package;
              description = "The theme package to be used for GTK programs";
              default = pkgs.catppuccin-gtk.override {
                size = "compact";
                accents = ["sapphire"];
                variant = "mocha";
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
              descriptiion = "The size of the font";
              default = 14;
            };
          };
        };
      };
    };
  };
}
