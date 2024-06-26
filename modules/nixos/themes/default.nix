{ lib, ... }:
let
  inherit (lib) mkEnableOption;
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
  };
}
