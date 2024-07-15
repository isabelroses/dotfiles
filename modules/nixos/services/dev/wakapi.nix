{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  inherit (lib) template;
  inherit (lib.modules) mkIf;
  inherit (lib.services) mkServiceOption;
  inherit (lib.secrets) mkSecret;

  rdomain = config.networking.domain;
  cfg = config.garden.services.dev.wakapi;
in
{
  imports = [ inputs.beapkgs.nixosModules.default ];

  options.garden.services.dev.wakapi = mkServiceOption "wakapi" {
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

        passwordSaltFile = config.age.secrets.wakapi.path;
        smtpPasswordFile = config.age.secrets.wakapi-mailer.path;

        settings = {
          app.avatar_url_template = "https://www.gravatar.com/avatar/{email_hash}.png";

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

      nginx.virtualHosts.${cfg.domain} = template.ssl rdomain;
    };
  };
}
