{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption mkSystemSecret;

  rdomain = config.networking.domain;
  cfg = config.garden.services.vikunja;
in
{
  options.garden.services.vikunja = mkServiceOption "vikunja" {
    domain = "todo.${rdomain}";
    port = 3456;
  };

  config = mkIf cfg.enable {
    sops.secrets.vikunja-env = mkSystemSecret {
      file = "vikunja";
      key = "env";
      owner = "vikunja";
      group = "vikunja";
    };

    garden.services = {
      redis.enable = true;
      postgresql.enable = true;
    };

    services = {
      vikunja = {
        enable = true;

        inherit (cfg) port;
        frontendHostname = cfg.domain;
        frontendScheme = "https";

        environmentFiles = [ config.sops.secrets.vikunja-env.path ];

        database = {
          type = "postgres";
          host = "/run/postgresql";
          user = "vikunja";
          database = "vikunja";
        };

        settings = {
          service.enableregistration = false;

          defaultsettings = {
            avatar_provider = "gravatar";
            week_start = 1; # monday
          };

          mailer = {
            enabled = true;
            host = config.garden.services.mailserver.domain;
            port = 465;
            forcessl = true;

            authtype = "login";
            fromemail = "noreply@${rdomain}";
            username = "noreply@${rdomain}";
          };

          openid = {
            enabled = true;
            redirecturl = "https://${cfg.domain}/auth/openid/";
            providers =
              let
                sso = config.garden.services.kanidm.domain;
              in
              [
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

      nginx.virtualHosts.${cfg.domain} = {
        locations."/".proxyPass = "http://${cfg.host}:${toString cfg.port}";
      };

      postgresql = {
        ensureDatabases = [ "vikunja" ];
        ensureUsers = lib.singleton {
          name = "vikunja";
          ensureDBOwnership = true;
        };
      };
    };

    users = {
      groups.vikunja = { };

      users."vikunja" = {
        group = "vikunja";
        createHome = false;
        isSystemUser = true;
      };
    };
  };
}
