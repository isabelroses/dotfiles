{ config, lib, ... }:
let
  inherit (lib) mkIf mkServiceOption;

  cfg = config.garden.services.database.influxdb;
in
{
  options.garden.services.database.influxdb = mkServiceOption "influxdb" { };

  config = mkIf cfg.enable {
    services.influxdb2 = {
      enable = true;
    };
  };
}
