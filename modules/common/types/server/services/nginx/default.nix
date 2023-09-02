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
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
      '';

      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      virtualHosts = let
        mkProxy = endpoint: port: extra: {
          "${endpoint}" = {
            proxyPass = "http://127.0.0.1:${toString port}";
            proxyWebsockets = true;
            extraConfig = extra;
          };
        };

        template = {
          forceSSL = true;
          enableACME = true;
        };
      in {
        # website + other stuff
        "${domain}" =
          mkIf (config.modules.usrEnv.services.isabelroses-web.enable)
          template
          // {
            serverAliases = ["${domain}"];
            root = "/home/isabel/dev/${domain}-pub";
          };

        # vaultwawrden
        "vault.${domain}" =
          mkIf (config.modules.usrEnv.services.vaultwarden.enable)
          template
          // {
            locations = mkProxy "/" "${config.services.vaultwarden.config.ROCKET_PORT}" "proxy_pass_header Authorization;";
          };

        # gitea
        "git.${domain}" =
          mkIf (config.modules.usrEnv.services.gitea.enable)
          template
          // {
            locations = mkProxy "/" "${config.services.gitea.settings.server.HTTP_PORT}";
          };

        "mail.${domain}" = mkIf (config.modules.usrEnv.services.mailserver.enable) template;
        "webmail.${domain}" = mkIf (config.modules.usrEnv.services.mailserver.enable) template;

        "search.${domain}" =
          mkIf (config.modules.usrEnv.services.searxng.enable)
          template
          // {
            locations = mkProxy "/" "8888" ''
              access_log /dev/null;
              error_log /dev/null;
              proxy_connect_timeout 60s;
              proxy_send_timeout 60s;
              proxy_read_timeout 60s;
            '';
          };
      };
    };
  };
}
