{pkgs, ...}: {
  services = {
    # monitor and control temparature
    thermald.enable = true;
    # handle ACPI events
    acpid.enable = true;
    # discard blocks that are not in use by the filesystem, good for SSDs
    fstrim.enable = true;
    # firmware updater for machine hardware
    fwupd.enable = true;
    # limit systemd journal size
    journald.extraConfig = ''
      SystemMaxUse=50M
      RuntimeMaxUse=10M
    '';
  };
}
