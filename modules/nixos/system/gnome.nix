{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkForce;
in
{
  config = mkIf config.garden.profiles.graphical.enable {
    services = {
      udev.packages = [ pkgs.gnome-settings-daemon ];

      gnome = {
        glib-networking.enable = true;

        # TODO: remove this in favour of the new gcr implementation
        # https://github.com/NixOS/nixpkgs/pull/379731
        gnome-keyring.enable = true; # this makes it so i don't have to enter my password every time i log in

        # I don't need remote desktop
        gnome-remote-desktop.enable = mkForce false;
      };
    };
  };
}
