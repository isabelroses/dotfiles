{ lib, config, ... }:
let
  inherit (lib) template;
  inherit (lib.modules) mkIf;
  inherit (lib.services) mkServiceOption;

  rdomain = config.networking.domain;
  cfg = config.garden.services.monitoring.uptime-kuma;
in
{
  options.garden.services.monitoring.uptime-kuma = mkServiceOption "uptime-kuma" {
    port = 3500;
    domain = "status.${rdomain}";
  };

  config = mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;

      # https://github.com/louislam/uptime-kuma/wiki/Environment-Variables
      settings = {
        PORT = "${toString cfg.port}";
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      locations."/" = {
        proxyPass = "http://${cfg.host}:${toString cfg.port}";
        proxyWebsockets = true;
      };
    } // template.ssl rdomain;
  };
}
