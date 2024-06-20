{ lib, pkgs, ... }:
let
  inherit (lib) mkOption mkEnableOption types;
in
{
  imports = [
    ./gtk.nix
    ./qt.nix
    ./catppuccin.nix
  ];

  options.modules.style = {
    forceGtk = mkEnableOption "Force GTK applications to use the GTK theme";
    useKvantum = mkEnableOption "Use Kvantum to theme QT applications";

    pointerCursor = {
      name = mkOption {
        type = types.str;
        description = "The name of the cursor inside the package";
        default = "catppuccin-mocha-dark-cursors";
      };

      package = mkOption {
        type = types.package;
        description = "The package providing the cursors";
        default = pkgs.catppuccin-cursors.mochaDark;
      };

      size = mkOption {
        type = types.int;
        description = "The size of the cursor";
        default = 24;
      };
    };
  };
}
