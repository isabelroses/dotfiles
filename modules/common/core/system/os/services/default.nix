{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./systemd.nix
    inputs.vscode-server.nixosModules.default
  ];
  services = {
    vscode-server.enable = config.modules.services.vscode-server.enable;
    # monitor and control temparature
    thermald.enable = true;
    # discard blocks that are not in use by the filesystem, good for SSDs
    fstrim.enable = true;
    # firmware updater for machine hardware
    fwupd.enable = true;
    # Not using lvm
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
