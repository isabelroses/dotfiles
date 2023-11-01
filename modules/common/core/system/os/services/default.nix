{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkDefault;
  inherit (config.modules) device;
in {
  imports = [
    ./systemd.nix
    inputs.vscode-server.nixosModules.default
  ];
  services = {
    # compress half of the ram to use as swap
    # basically, get more memory per memory
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 90; # defaults to 50
    };

    # enable the vscode server
    vscode-server.enable = config.modules.services.vscode-server.enable;
    # monitor and control temparature
    thermald.enable = true;
    # discard blocks that are not in use by the filesystem, good for SSDs
    fstrim.enable = true;
    # firmware updater for machine hardware
    fwupd.enable = true;
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
