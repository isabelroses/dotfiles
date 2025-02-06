{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.services) mkServiceOption;

  cfg = config.garden.services.influxdb;
in
{
  options.garden.services.influxdb = mkServiceOption "influxdb" { };

  config = mkIf cfg.enable {
    services.influxdb2 = {
      enable = true;
    };
  };
}
