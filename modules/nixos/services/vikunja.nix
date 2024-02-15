{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf template;

  rdomain = config.networking.domain;
  cfg = config.modules.services.vikunja;
in {
  config = mkIf cfg.enable {
    modules.services = {
      networking.nginx.enable = true;
      database = {
        redis.enable = true;
        postgresql.enable = true;
      };
    };

    services = {
      vikunja = {
        enable = true;
        setupNginx = true;
        frontendHostname = cfg.domain;
        frontendScheme = "https";

        environmentFiles = [config.age.secrets.vikunja-env.path];

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
            host = config.modules.services.mailserver.domain;
            port = 465;
            forcessl = true;

            authtype = "login";
            fromemail = "noreply@${rdomain}";
            username = "noreply@${rdomain}";
          };

          openid = {
            enabled = true;
            redirecturl = "https://${cfg.domain}/auth/openid/";
            providers = let
              sso = config.modules.services.kanidm.domain;
            in [
              {
                name = "Isabel's SSO";
                authurl = "https://${sso}/oauth2/openid/vikunja/";
                logouturl = "https://${sso}/logout";
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

      nginx.virtualHosts.${cfg.domain} = template.ssl rdomain;
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
