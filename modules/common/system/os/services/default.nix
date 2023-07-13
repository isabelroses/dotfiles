{lib, ...}: {
  imports = [./systemd.nix];
  services = {
    # monitor and control temparature
    thermald.enable = true;
    # handle ACPI events
    acpid.enable = true;
    # discard blocks that are not in use by the filesystem, good for SSDs
    fstrim.enable = true;
    # firmware updater for machine hardware
    fwupd.enable = true;
    # I don't use lvm, can be disabled
    lvm.enable = lib.mkDefault false;
    # enable smartd monitoering
    smartd.enable = true;
    # limit systemd journal size
    journald.extraConfig = ''
      SystemMaxUse=100M
      RuntimeMaxUse=50M
      SystemMaxFileSize=50M
    '';
  };
}
