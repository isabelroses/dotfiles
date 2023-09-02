{
  config,
  lib,
  ...
}:
with lib; let
  smb = config.modules.usrEnv.services.smb;
in {
  config = mkIf ((smb.enable) && (smb.recive.general)) {
    fileSystems."/mnt/general" = {
      device = "//192.168.86.4/sharedata";
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
