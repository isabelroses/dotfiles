{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.services) mkServiceOption;
  inherit (self.lib) mkSystemSecret;

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
      wakapi = mkSystemSecret {
        file = "wakapi";
        owner = "wakapi";
        group = "wakapi";
      };

      wakapi-mailer = mkSystemSecret {
        file = "wakapi-mailer";
        owner = "wakapi";
        group = "wakapi";
      };
    };

    garden.services = {
      postgresql.enable = true;
    };

    systemd.services.wakapi.serviceConfig = {
      PrivateTmp = true;
      PrivateUsers = true;
      PrivateDevices = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      NoNewPrivileges = true;
      ProtectSystem = lib.mkForce "full";
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
    };

    services = {
      wakapi = {
        enable = true;

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
      };
    };
  };
}
