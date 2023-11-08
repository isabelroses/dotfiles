{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf sslTemplate;
  inherit (config.networking) domain;

  sys = config.modules.services;
  cfg = sys.monitoring;

  port = 3100;
in {
  config = mkIf cfg.grafana.enable {
    networking.firewall.allowedTCPPorts = [port];

    modules.services.database = {
      postgresql.enable = true;
    };

    services = {
      grafana = {
        enable = true;
        settings = {
          server = {
            http_port = port;
            http_addr = "0.0.0.0";
            domain = "graph.${domain}";
            enforce_domain = true;
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

          security = {
            cookie_secure = true;
          };

          analytics = {
            reporting_enabled = false;
            check_for_updates = false;
          };

          "auth.anonymous".enabled = false;
          "auth.basic".enabled = false;

          users = {
            allow_signup = false;
          };
        };

        provision = {
          enable = true;
          datasources.settings = {
            datasources = [
              (mkIf cfg.prometheus.enable {
                name = "Prometheus";
                type = "prometheus";
                access = "proxy";
                orgId = 1;
                uid = "PBFA97CFB590B2093";
                url = "http://127.0.0.1:${toString config.services.prometheus.port}";
                isDefault = true;
                version = 1;
                editable = true;
                jsonData = {
                  graphiteVersion = "1.1";
                  tlsAuth = false;
                  tlsAuthWithCACert = false;
                };
              })

              (mkIf cfg.loki.enable {
                name = "Loki";
                type = "loki";
                access = "proxy";
                url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
              })

              (mkIf sys.database.postgresql.enable {
                name = "PostgreSQL";
                type = "postgres";
                access = "proxy";
                url = "http://127.0.0.1:9103";
              })
            ];
          };
        };
      };

      nginx.virtualHosts.${config.services.grafana.settings.server.domain} =
        {
          locations."/" = {
            proxyPass = with config.services.grafana.settings.server; "http://${toString http_addr}:${toString http_port}/";
            proxyWebsockets = true;
          };
        }
        // sslTemplate;
    };
  };
}
