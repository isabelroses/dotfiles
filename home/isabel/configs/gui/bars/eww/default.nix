{
  lib,
  self',
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib) isWayland;

  ewwPackage = if isWayland osConfig then pkgs.eww-wayland else pkgs.eww;
in
{
  config = lib.mkIf ((isWayland osConfig) && osConfig.modules.programs.gui.bars.eww.enable) {
    home.packages = with pkgs; [
      socat
      jaq
      acpi
      upower
      inotify-tools
      blueberry
      gnome.gnome-bluetooth
      gtk3
      pango
      cairo
      harfbuzz
      gdk-pixbuf
      glib
      self'.packages.patched-gjs # patched gjs version
    ];

    programs.eww = {
      enable = true;
      package = ewwPackage;
      configDir = ./.;
    };
  };
}
