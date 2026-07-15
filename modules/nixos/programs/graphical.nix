{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
in
{
  config = mkIf config.garden.profiles.graphical.enable {
    # we need dconf to interact with gtk
    programs.dconf.enable = true;

    services = {
      # keyring manager
      oo7.enable = true;

      udev.packages = [ pkgs.gnome-settings-daemon ];

      gnome.glib-networking.enable = true;
    };

    garden.packages = {
      inherit (pkgs) cosmic-icons;
    };
  };
}
