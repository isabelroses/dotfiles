{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.services) mkServiceOption;

  rdomain = config.networking.domain;
  cfg = config.garden.services.uptime-kuma;
in
{
  options.garden.services.uptime-kuma = mkServiceOption "uptime-kuma" {
    port = 3008;
    domain = "status.${rdomain}";
  };

  config = mkIf cfg.enable {
    services = {
      uptime-kuma = {
        enable = true;

        # https://github.com/louislam/uptime-kuma/wiki/Environment-Variables
        settings = {
          HOST = cfg.host;
          PORT = toString cfg.port;
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/" = {
          proxyPass = "http://${cfg.host}:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
