{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  share = config.modules.system.smb;
in {
  imports = [
    ./media
    ./genral
  ];

  config = mkIf (share.enable) {
    environment.systemPackages = [pkgs.cifs-utils];
  };
}
