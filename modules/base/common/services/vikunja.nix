{
  config,
  lib,
  ...
}: let
  inherit (config.networking) domain;

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
        frontendHostname = "todo.${domain}";
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
            host = "mail.isabelroses.com";
            port = 465;
            forcessl = true;

            authtype = "login";
            fromemail = "noreply@isabelroses.com";
            username = "noreply@isabelroses.com";
          };

          # redis
          # redis = {
          #   enabled = true;
          #   host = "/run/redis-vikunja/redis.sock";
          #   db = 0;
          # };
        };
      };

      nginx.virtualHosts.${config.services.vikunja.frontendHostname} = template.ssl;
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
