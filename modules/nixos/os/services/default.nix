{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkDefault;
  inherit (config.modules) device;
in {
  imports = [
    ./systemd.nix
    ./zram.nix
  ];

  services = {
    # monitor and control temperature
    thermald.enable = true;
    # discard blocks that are not in use by the filesystem, good for SSDs
    fstrim.enable = true;
    # firmware updater for machine hardware
    fwupd = {
      enable = true;
      daemonSettings.EspLocation = config.boot.loader.efi.efiSysMountPoint;
    };
    # Not using lvm
    lvm.enable = mkDefault false;
    # enable smartd monitoering
    smartd.enable = true;
    # limit systemd journal size
    # https://wiki.archlinux.org/title/Systemd/Journal#Persistent_journals
    journald.extraConfig = mkIf (device.type != "server") ''
      SystemMaxUse=100M
      RuntimeMaxUse=50M
      SystemMaxFileSize=50M
    '';
  };
}
