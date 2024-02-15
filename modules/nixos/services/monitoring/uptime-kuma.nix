{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf template;

  rdomain = config.networking.domain;
  cfg = config.modules.services.monitoring.uptime-kuma;
in {
  config = mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;

      # https://github.com/louislam/uptime-kuma/wiki/Environment-Variables
      settings = {
        PORT = "${toString cfg.port}";
      };
    };

    services.nginx.virtualHosts.${cfg.domain} =
      {
        locations."/" = {
          proxyPass = "http://${cfg.host}:${toString cfg.port}";
          proxyWebsockets = true;
        };
      }
      // template.ssl rdomain;
  };
}
