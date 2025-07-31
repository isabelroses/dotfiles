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

        gnome-keyring.enable = true; # this makes it so i don't have to enter my password every time i log in

        # since https://github.com/NixOS/nixpkgs/pull/379731
        # was merged, gcr-ssh-agent is enabled by ggnome-keyring.enable
        # but i don't want it on beacuse i configure my gpg agent through home-manager
        gcr-ssh-agent.enable = false;

        # I don't need remote desktop
        gnome-remote-desktop.enable = mkForce false;
      };
    };
  };
}
