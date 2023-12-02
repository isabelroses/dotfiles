{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.networking) domain;
in {
  config = lib.mkIf config.modules.services.wakapi.enable {
    modules.services.database = {
      postgresql.enable = true;
    };

    services = {
      wakapi = {
        enable = true;
        package = pkgs.wakapi;

        domain = "wakapi.${domain}";
        port = 15912;
        nginx.enable = true;

        db = {
          host = "/run/postgresql";
        };

        passwordSaltFile = config.sops.secrets.wakapi.path;
        settings = {
          app.avatar_url_template = "https://www.gravatar.com/avatar/{email_hash}.png";
          mail.enabled = false;
          security = {
            allow_signup = false;
            disable_frontpage = true;
          };
        };
      };

      nginx.virtualHosts.${config.services.wakapi.domain} = lib.template.ssl;
    };
  };
}
