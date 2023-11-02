{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  smb = config.modules.services.smb;
in {
  imports = [
    ./recive
  ];

  config = mkIf (smb.enable) {
    environment.systemPackages = [pkgs.cifs-utils];
  };
}
