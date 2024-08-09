{ lib, pkgs, ... }:
let
  inherit (lib.modules) mkDefault;
in
{
  services = {
    # enable GVfs, a userspace virtual filesystem.
    gvfs.enable = true;

    # storage daemon required for udiskie auto-mount
    udisks2.enable = true;

    dbus = {
      enable = true;
      # Use the faster dbus-broker instead of the classic dbus-daemon
      implementation = "broker";

      packages = builtins.attrValues { inherit (pkgs) dconf gcr udisks2; };
    };

    # disable chrony in favor if systemd-timesyncd
    timesyncd.enable = mkDefault true;
    chrony.enable = mkDefault false;
  };
}
