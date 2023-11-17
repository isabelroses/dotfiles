{
  config,
  lib,
  pkgs,
  ...
}: let
  smb = config.modules.services.smb;
in {
  imports = [
    ./recive
  ];

  config = lib.mkIf (smb.enable) {
    environment.systemPackages = [pkgs.cifs-utils];
  };
}
