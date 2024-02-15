{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.modules.services;
in {
  config = mkIf cfg.database.influxdb.enable {
    services.influxdb2 = {
      enable = true;
    };
  };
}
