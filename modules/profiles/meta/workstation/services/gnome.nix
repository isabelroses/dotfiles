{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.modules) device;
  acceptedTypes = ["desktop" "laptop" "wsl" "hybrid" "lite"];
in {
  config = lib.mkIf (builtins.elem device.type acceptedTypes) {
    services = {
      udev.packages = with pkgs; [
        gnome.gnome-settings-daemon
      ];

      gnome = {
        evolution-data-server.enable = true;
        gnome-online-accounts.enable = true;
        gnome-keyring.enable = true;

        # stupid thing i want disabled
        gnome-remote-desktop.enable = lib.mkForce false;
      };
    };
  };
}
