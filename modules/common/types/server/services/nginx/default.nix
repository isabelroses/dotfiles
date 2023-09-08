{
  lib,
  config,
  ...
}: let
  cfg = config.modules.usrEnv.services.nginx;
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

    services.nginx = lib.mkIf cfg.enable {
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
            locations."/" = {
              root = "/var/www/${domain}";
              index = "index.php";
              extraConfig = ''
                try_files $uri $uri/ $uri.html $uri.php$is_args$query_string;

                location ~* \.php(/|$) {
                  try_files $uri =404;

                  include ${config.services.nginx.package}/conf/fastcgi_params;
                  include ${config.services.nginx.package}/conf/fastcgi.conf;

                  fastcgi_pass  unix:${config.services.phpfpm.pools.${domain}.socket};
                  fastcgi_split_path_info ^(.+\.php)(/.+)$;
                  fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                  fastcgi_param PATH_INFO $fastcgi_path_info;
                }
              '';
            };
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
        "git.${domain}" =
          template
          // {
            locations."/".proxyPass = "http://127.0.0.1:${toString config.services.gitea.settings.server.HTTP_PORT}";
          };

        "mail.${domain}" = template;
        "webmail.${domain}" = template;

        "wakapi.${domain}" =
          template
          // {
            locations."/".proxyPass = "http://127.0.0.1:${toString config.services.wakapi.port}";
          };

        /*
         "search.${domain}" =
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
