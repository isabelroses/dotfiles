{ lib, config, ... }:
let
  inherit (lib) template;
  inherit (lib.modules) mkIf;
  inherit (lib.services) mkServiceOption;

  rdomain = config.networking.domain;
  cfg = config.garden.services.photoprism;
in
{
  options.garden.services.photoprism = mkServiceOption "photoprism" {
    port = 2342;
    host = "0.0.0.0";
    domain = "photos.${rdomain}";
  };

  config = mkIf cfg.enable {
    garden.services = {
      nginx.enable = true;
      mysql.enable = true;
    };

    services = {
      photoprism = {
        enable = true;
        inherit (cfg) port;
        address = cfg.host;

        originalsPath = "/var/lib/private/photoprism/originals";

        settings = {
          PHOTOPRISM_ADMIN_USER = "admin";
          PHOTOPRISM_ADMIN_PASSWORD = "L38*%puzpXX!j$7!";
          PHOTOPRISM_DEFAULT_LOCALE = "en";
          PHOTOPRISM_DATABASE_DRIVER = "mysql";
          PHOTOPRISM_DATABASE_NAME = "photoprism";
          PHOTOPRISM_DATABASE_SERVER = "/run/mysqld/mysqld.sock";
          PHOTOPRISM_DATABASE_USER = "photoprism";
          PHOTOPRISM_SITE_URL = "https://${cfg.domain}";
          PHOTOPRISM_SITE_TITLE = "My PhotoPrism";
        };
      };

      nginx.virtualHosts.${cfg.domain} = template.ssl rdomain;
    };
  };
}
