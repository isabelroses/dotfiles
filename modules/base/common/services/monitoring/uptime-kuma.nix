{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf template;
  inherit (config.networking) domain;

  cfg = config.modules.services.monitoring.uptime-kuma;
in {
  config = mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;

      # https://github.com/louislam/uptime-kuma/wiki/Environment-Variables
      settings = {
        PORT = "3500";
        # DATA_DIR = mkForce "/srv/storage/uptime-kuma"; # refuses to work with me
      };
    };

    services.nginx.virtualHosts."status.${domain}" =
      {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.uptime-kuma.settings.PORT}";
          proxyWebsockets = true;
        };
      }
      // template.ssl domain;
  };
}
