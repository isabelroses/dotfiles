{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) template;
  inherit (lib.modules) mkIf;
  inherit (lib.services) mkServiceOption;
  inherit (lib.secrets) mkSecret;

  rdomain = config.networking.domain;
  cfg = config.garden.services.wakapi;
in
{
  options.garden.services.wakapi = mkServiceOption "wakapi" {
    port = 15912;
    domain = "wakapi.${rdomain}";
  };

  config = mkIf cfg.enable {
    age.secrets = {
      wakapi = mkSecret {
        file = "wakapi";
        owner = "wakapi";
        group = "wakapi";
      };

      wakapi-mailer = mkSecret {
        file = "wakapi-mailer";
        owner = "wakapi";
        group = "wakapi";
      };
    };

    garden.services = {
      nginx.enable = true;
      postgresql.enable = true;
    };

    services = {
      wakapi = {
        enable = true;
        package = pkgs.wakapi;

        passwordSaltFile = config.age.secrets.wakapi.path;
        smtpPasswordFile = config.age.secrets.wakapi-mailer.path;

        # setup out postgresql database
        database.createLocally = true;

        settings = {
          app.avatar_url_template = "https://www.gravatar.com/avatar/{email_hash}.png";

          server = {
            inherit (cfg) port;
            public_url = "https://${cfg.domain}";
          };

          db = {
            dialect = "postgres";
            host = "/run/postgresql";
            port = 5432; # this needs to be set otherwise the service will fail
            name = "wakapi";
            user = "wakapi";
          };

          security = {
            allow_signup = false;
            disable_frontpage = true;
          };

          mail =
            let
              mailer = "noreply@${rdomain}";
            in
            {
              enabled = true;
              sender = "<${mailer}>";
              provider = "smtp";
              smtp = {
                host = "mail.${rdomain}";
                port = 465;
                username = mailer;
                tls = true;
              };
            };
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/".proxyPass = "http://${cfg.host}:${toString cfg.port}";
      } // template.ssl rdomain;
    };
  };
}
