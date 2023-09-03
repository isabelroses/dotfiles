{
  lib,
  config,
  ...
}: let
  domain = "isabelroses.com";
  inherit (lib) mkIf;
in {
  config = {
    networking.domain = domain;

    security = {
      acme = {
        acceptTerms = true;
        defaults.email = "isabel@${domain}";
      };
    };

    services.nginx = {
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

      virtualHosts = let
        template = {
          forceSSL = true;
          enableACME = true;
        };
      in {
        # website + other stuff
        "${domain}" =
          template
          // {
            serverAliases = ["${domain}"];
            root = "/var/www/${domain}";
          };

        # vaultwawrden
        "vault.${domain}" =
          template
          // {
            locations."/" = {
              proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
              extraConfig = "proxy_pass_header Authorization;";
            };
          };

        # gitea
        "gitea.${domain}" =
          template
          // {
            locations."/".proxyPass = "http://127.0.0.1:${toString config.services.gitea.settings.server.HTTP_PORT}";
          };

        "mail.${domain}" = template;
        "webmail.${domain}" = template;

        /* "search.${domain}" =
          template
          // {
            locations."/".proxyPass = "http://127.0.0.1:8888";
            extraConfig = ''
              access_log /dev/null;
              error_log /dev/null;
              proxy_connect_timeout 60s;
              proxy_send_timeout 60s;
              proxy_read_timeout 60s;
            '';
          };
          */
      };
    };
  };
}
