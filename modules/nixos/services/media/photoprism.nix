{ lib, config, ... }:
let
  inherit (lib) mkIf template mkServiceOption;
  rdomain = config.networking.domain;
  cfg = config.modules.services.media.photoprism;
in
{
  options.modules.services.media.photoprism = mkServiceOption "photoprism" {
    port = 2342;
    host = "0.0.0.0";
    domain = "photos.${rdomain}";
  };

  config = mkIf cfg.enable {
    modules.services = {
      networking.nginx.enable = true;
      database.mysql.enable = true;
    };

    services = {
      photoprism = {
        enable = true;
        inherit (cfg) port;
        originalsPath = "/var/lib/private/photoprism/originals";
        address = cfg.host;
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
