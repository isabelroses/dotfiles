{ lib, pkgs, ... }:
let
  inherit (lib) mkOption mkEnableOption types;
in
{
  options.modules.style.gtk = {
    enable = mkEnableOption "GTK theming options";
    usePortal = mkEnableOption "native desktop portal use for filepickers";

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
          accent = "pink";
          flavor = "mocha";
        };
      };
    };

    font = {
      name = mkOption {
        type = types.str;
        description = "The name of the font that will be used for GTK applications";
        default = "CommitMono";
      };

      size = mkOption {
        type = types.int;
        description = "The size of the font";
        default = 14;
      };
    };
  };
}
