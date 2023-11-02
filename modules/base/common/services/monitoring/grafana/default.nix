{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf sslTemplate;
  inherit (config.networking) domain;

  cfg = config.modules.services.monitoring.grafana;

  port = 3100;
in {
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [port];

    modules.services.database = {
      postgresql.enable = true;
    };

    services = {
      grafana = {
        enable = true;
        settings = {
          analytics = {
            reporting_enabled = false;
            check_for_updates = false;
          };

          server = {
            http_port = port;
            http_addr = "0.0.0.0";
            domain = "graph.${domain}";
            enforce_domain = true;
          };

          "auth.anonymous".enabled = false;
          "auth.basic".enabled = false;

          users = {
            allow_signup = false;
          };

          database = {
            type = "postgres";
            host = "/run/postgresql";
            name = "grafana";
            user = "grafana";
            ssl_mode = "disable";
          };

          smtp = let
            mailer = "grafana@${domain}";
          in {
            enabled = true;

            user = mailer;
            password = "$__file{" + config.sops.secrets.mailserver-grafana-nohash.path + "}";

            host = "mail.${domain}:465";
            from_address = mailer;
            startTLS_policy = "MandatoryStartTLS";
          };
        };

        provision = {
          datasources.settings = {
            datasources = [
              {
                name = "Prometheus";
                type = "prometheus";
                url = "http://localhost:9100";
                orgId = 1;
              }
            ];
          };
        };
      };

      nginx.virtualHosts.${config.services.grafana.settings.server.domain} =
        {
          locations."/" = {
            proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}/";
            proxyWebsockets = true;
          };
        }
        // sslTemplate;
    };
  };
}
