{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
  cfg = config.modules.style;
in {
  imports = [./gtk.nix ./qt.nix];
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
            description = ''
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
      };
    };
  };
}
