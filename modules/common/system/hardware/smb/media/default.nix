{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  share = config.modules.system.smb;
in {
  config = mkIf ((share.enable) && (share.media.enable)) {
    fileSystems."/mnt/media" = {
      device = "//192.168.86.4/media";
      fsType = "cifs";
      options = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.after=network-online.target"
        "x-systemd.mount-timeout=90"
        "uid=1000"
        "gid=1000"
      ];
    };
  };
}
