{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.garden.profiles.graphical.enable {
    programs = {
      # we need dconf to interact with gtk
      dconf.enable = true;

      # gnome's keyring manager
      seahorse.enable = true;
    };

    garden.packages = {
      inherit (pkgs) cosmic-icons;
    };
  };
}
