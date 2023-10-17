{
  lib,
  config,
  ...
}: let
  cfg = config.modules.services;
  inherit (lib) mkIf;
  domain = "isabelroses.com";
in {
  config = {
    networking.domain = domain;

    security = {
      acme = {
        acceptTerms = true;
        defaults.email = "isabel@${domain}";
      };
    };

    services.nginx = mkIf cfg.nginx.enable {
      enable = true;
      commonHttpConfig = ''
        real_ip_header CF-Connecting-IP;
        add_header 'Referrer-Policy' 'origin-when-cross-origin';
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options nosniff;
      '';

      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      virtualHosts = {
        # website + other stuff
        "${domain}" = mkIf cfg.isabelroses-web.enable {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = "http://127.0.0.1:3000";
        };

        # vaultwawrden
        "vault.${domain}" = mkIf cfg.vaultwarden.enable {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
            extraConfig = "proxy_pass_header Authorization;";
          };
        };

        # gitea
        "git.${domain}" = mkIf cfg.gitea.enable {
          locations."/".proxyPass = "http://127.0.0.1:${toString config.services.gitea.settings.server.HTTP_PORT}";
          forceSSL = true;
          enableACME = true;
        };

        # mailserver
        "mail.${domain}" = mkIf cfg.mailserver.enable {
          forceSSL = true;
          enableACME = true;
        };
        "rspamd.${domain}" = mkIf (cfg.mailserver.enable && cfg.mailserver.rspamd-web.enable) {
          forceSSL = true;
          enableACME = true;
          basicAuthFile = config.sops.secrets.rspamd-web.path;
          locations."/".proxyPass = "http://unix:/run/rspamd/worker-controller.sock:/";
        };
        "webmail.${domain}" = mkIf cfg.mailserver.enable {
          forceSSL = true;
          enableACME = true;
        };

        # searxng
        "search.${domain}" = mkIf cfg.searxng.enable {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = "http://127.0.0.1:8888";
          extraConfig = ''
            access_log /dev/null;
            error_log /dev/null;
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
          '';
        };

        "graph.${domain}" = mkIf cfg.monitoring.grafana.enable {
          locations."/" = {
            proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}/";
            proxyWebsockets = true;
          };
          addSSL = true;
          enableACME = true;
        };

        "flux.${domain}" = mkIf cfg.miniflux.enable {
          locations."/".proxyPass = "http://unix:${config.systemd.services.miniflux.environment.LISTEN_ADDR}";
          forceSSL = true;
          enableACME = true;
        };

        "matrix.${domain}" = mkIf cfg.matrix.enable {
          locations."/".proxyPass = "http://127.0.0.1:8008";
          forceSSL = true;
          enableACME = true;
        };
      };
    };
  };
}
