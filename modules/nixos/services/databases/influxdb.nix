{ config, lib, ... }:
let
  inherit (lib) mkIf mkServiceOption;

  cfg = config.modules.services.database.influxdb;
in
{
  options.modules.services.database.influxdb = mkServiceOption "influxdb" { };

  config = mkIf cfg.enable {
    services.influxdb2 = {
      enable = true;
    };
  };
}
