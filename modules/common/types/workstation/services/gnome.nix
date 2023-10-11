{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  device = config.modules.device;
  acceptedTypes = ["desktop" "laptop" "hybrid" "lite"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes) {
    services = {
      udev.packages = with pkgs; [
        gnome.gnome-settings-daemon
      ];

      gnome = {
        evolution-data-server.enable = true;
        # optional to use google/nextcloud calendar
        gnome-online-accounts.enable = true;
        # optional to use google/nextcloud calendar
        gnome-keyring.enable = true;
        # hard fails rebuilds for whatever reason, PLEASE stay disabled
        # spoiler: it didn't - building gnome-control-center still breaks rebuilds
        # entirely because of gnome-remote-desktop
        gnome-remote-desktop.enable = lib.mkForce false;
      };
    };
  };
}
