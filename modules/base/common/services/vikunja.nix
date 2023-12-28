{
  config,
  lib,
  ...
}: let
  inherit (config.networking) domain;
  vikunja_domain = "todo.${domain}";

  cfg = config.modules.services.vikunja;

  inherit (lib) mkIf template;
in {
  config = mkIf cfg.enable {
    modules.services.database = {
      postgresql.enable = true;
    };

    services = {
      vikunja = {
        enable = true;
        setupNginx = true;
        frontendHostname = vikunja_domain;
        frontendScheme = "https";

        environmentFiles = [config.sops.secrets.vikunja-env.path];

        database = {
          type = "postgres";
          host = "/run/postgresql";
          user = "vikunja-api";
          database = "vikunja-api";
        };

        settings = {
          service.enableregistration = false;

          defaultsettings = {
            avatar_provider = "gravatar";
            week_start = 1; # monday
          };

          mailer = {
            enabled = true;
            host = "mail.${domain}";
            port = 465;
            forcessl = true;

            authtype = "login";
            fromemail = "noreply@${domain}";
            username = "noreply@${domain}";
          };

          openid = {
            enabled = true;
            redirecturl = "https://${vikunja_domain}/auth/openid/";
            providers = [
              {
                name = "Isabel's SSO";
                authurl = "https://sso.${domain}/oauth2/openid/vikunja/";
                logouturl = "https://sso.${domain}/logout";
                clientid = "vikunja";
              }
            ];
          };

          # redis
          # redis = {
          #   enabled = true;
          #   host = "/run/redis-vikunja/redis.sock";
          #   db = 0;
          # };
        };
      };

      nginx.virtualHosts.${vikunja_domain} = template.ssl domain;
    };

    users = {
      groups.vikunja-api = {};

      users."vikunja-api" = {
        group = "vikunja-api";
        createHome = false;
        isSystemUser = true;
      };
    };
  };
}
