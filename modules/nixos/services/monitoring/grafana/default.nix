{ lib, config, ... }:
let
  inherit (lib) template;
  inherit (lib.modules) mkIf;
  inherit (lib.services) mkServiceOption;
  inherit (lib.secrets) mkSecret;

  rdomain = config.networking.domain;
  srv = config.garden.services;
  cfg = srv.monitoring.grafana;
in
{
  options.garden.services.monitoring.grafana = mkServiceOption "grafana" {
    port = 3100;
    host = "0.0.0.0";
    domain = "graph.${rdomain}";
  };

  config = mkIf cfg.enable {
    age.secrets = {
      grafana-oauth2 = mkSecret {
        file = "grafana-oauth2";
        owner = "grafana";
        group = "grafana";
      };

      mailserver-grafana-nohash = mkSecret {
        file = "mailserver/grafana-nohash";
        owner = "grafana";
        group = "grafana";
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];

    garden.services.database = {
      postgresql.enable = true;
    };

    services = {
      grafana = {
        enable = true;
        settings = {
          server = {
            root_url = "https://${cfg.domain}";
            http_port = cfg.port;
            http_addr = cfg.host;
            inherit (cfg) domain;
            enforce_domain = true;
          };

          database = {
            type = "postgres";
            host = "/run/postgresql";
            name = "grafana";
            user = "grafana";
            ssl_mode = "disable";
          };

          smtp =
            let
              mailer = "grafana@${cfg.domain}";
            in
            {
              enabled = true;

              user = mailer;
              password = "$__file{" + config.age.secrets.mailserver-grafana-nohash.path + "}";

              host = "${config.garden.services.mailserver.domain}:465";
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

          auth.disable_login_form = false;
          "auth.anonymous".enabled = false;
          "auth.basic".enabled = false;

          "auth.generic_oauth" =
            let
              sso = "https://${config.garden.services.kanidm.domain}";
            in
            {
              enabled = true;
              # auto_login = true;
              allow_signup = true;
              icon = "signin";
              name = "Kanidm";
              client_id = "grafana";
              client_secret = "$__file{${config.age.secrets.grafana-oauth2.path}}";
              use_pkce = true;
              scopes = "openid email profile";
              login_attribute_path = "preferred_username";
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
              (mkIf srv.monitoring.prometheus.enable {
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

              (mkIf srv.monitoring.loki.enable {
                name = "Loki";
                type = "loki";
                access = "proxy";
                url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
              })

              (mkIf srv.database.postgresql.enable {
                name = "PostgreSQL";
                type = "postgres";
                access = "proxy";
                url = "http://127.0.0.1:9103";
              })
            ];
          };
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/" = {
          proxyPass = "http://${cfg.host}:${toString cfg.port}/";
          proxyWebsockets = true;
        };
      } // template.ssl rdomain;
    };
  };
}
