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
    ./host
  ];

  config = mkIf (smb.enable) {
    environment.systemPackages = [pkgs.cifs-utils];
  };
}
