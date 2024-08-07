{ lib, pkgs, ... }:
let
  inherit (lib.modules) mkForce;
in
{
  services = {
    udev.packages = [ pkgs.gnome.gnome-settings-daemon ];

    gnome = {
      glib-networking.enable = true;
      gnome-keyring.enable = true; # this makes it so i don't have to enter my password every time i log in

      # I don't need remote desktop
      gnome-remote-desktop.enable = mkForce false;
    };
  };
}
