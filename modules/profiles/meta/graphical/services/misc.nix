{ lib, pkgs, ... }:
{
  services = {
    # enable GVfs, a userspace virtual filesystem.
    gvfs.enable = true;

    # thumbnail support on thunar
    tumbler.enable = true;

    # storage daemon required for udiskie auto-mount
    udisks2.enable = true;

    dbus = {
      packages = with pkgs; [
        dconf
        gcr
        udisks2
      ];
      enable = true;
      # Use the faster dbus-broker instead of the classic dbus-daemon
      implementation = "broker";
    };

    # disable chrony in favor if systemd-timesyncd
    timesyncd.enable = lib.mkDefault true;
    chrony.enable = lib.mkDefault false;
  };
}
