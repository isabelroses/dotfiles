{ lib, pkgs, ... }:
let
  inherit (lib.modules) mkForce;
in
{
  services = {
    udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

    gnome = {
      glib-networking.enable = true;
      evolution-data-server.enable = true;
      gnome-online-accounts.enable = true;
      gnome-keyring.enable = true; # this makes it so i don't have to enter my password every time i log in

      # I don't need remote desktop
      gnome-remote-desktop.enable = mkForce false;
    };
  };
}
