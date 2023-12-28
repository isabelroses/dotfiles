{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf template;
  inherit (config.networking) domain;

  sys = config.modules.services;
  cfg = sys.monitoring;

  port = 3100;
  grafana_domain = "graph.${domain}";
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
            root_url = "https://${grafana_domain}";
            http_port = port;
            http_addr = "0.0.0.0";
            domain = grafana_domain;
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

          auth = {
            disable_login_form = false;
          };

          "auth.anonymous".enabled = false;
          "auth.basic".enabled = false;

          "auth.generic_oauth" = let
            sso = "https://sso.${domain}";
          in {
            enabled = true;
            auto_login = true;
            name = "Kanidm";
            client_id = "grafana";
            use_pkce = true;
            scopes = ["openid" "profile" "email"];
            login_attribute_path = "prefered_username";
            email_attribute_path = "email";
            auth_url = "${sso}/ui/oauth2";
            token_url = "${sso}/oauth2/token";
            api_url = "${sso}/oauth2/openid/grafana/userinfo";
          };

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

      nginx.virtualHosts.${grafana_domain} =
        {
          locations."/" = {
            proxyPass = with config.services.grafana.settings.server; "http://${toString http_addr}:${toString http_port}/";
            proxyWebsockets = true;
          };
        }
        // template.ssl domain;
    };
  };
}
