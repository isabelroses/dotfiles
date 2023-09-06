{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
in {
  options = {
    modules = {
      style = {
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
              default = "RobotoMono Nerd Font Regular";
            };

            size = mkOption {
              type = types.int;
              description = "The size of the font";
              default = 14;
            };
          };
        };
      };
    };
  };
}
