{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf template;

  rdomain = config.networking.domain;
  cfg = config.modules.services.dev.wakapi;
in {
  config = mkIf cfg.enable {
    modules.services = {
      networking.nginx.enable = true;
      database.postgresql.enable = true;
    };

    services = {
      wakapi = {
        enable = true;
        package = pkgs.wakapi;

        inherit (cfg) domain port;
        nginx.enable = true;

        db = {
          host = "/run/postgresql";
        };

        passwordSaltFile = config.sops.secrets.wakapi.path;
        smtpPasswordFile = config.sops.secrets.wakapi-mailer.path;

        settings = {
          app.avatar_url_template = "https://www.gravatar.com/avatar/{email_hash}.png";

          security = {
            allow_signup = false;
            disable_frontpage = true;
          };

          mail = let
            mailer = "noreply@${rdomain}";
          in {
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

      nginx.virtualHosts.${cfg.domain} = template.ssl rdomain;
    };
  };
}
