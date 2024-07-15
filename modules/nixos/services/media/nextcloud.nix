{
  lib,
  pkgs,
  config,
  ...
}:
let
  rdomain = config.networking.domain;

  inherit (lib) template;
  inherit (lib.modules) mkIf;
  inherit (lib.services) mkServiceOption;
  inherit (lib.secrets) mkSecret;

  cfg = config.garden.services.media.nextcloud;
in
{
  options.garden.services.media.nextcloud = mkServiceOption "nextcloud" {
    domain = "cloud.${rdomain}";
  };

  config = mkIf cfg.enable {
    age.secrets.nextcloud-passwd = mkSecret {
      file = "nextcloud-passwd";
      owner = "nextcloud";
      group = "nextcloud";
    };

    garden.services = {
      networking.nginx.enable = true;
      database = {
        redis.enable = true;
        postgresql.enable = true;
      };
    };

    services = {
      nextcloud = {
        enable = true;
        package = pkgs.nextcloud29;

        # webs stuff
        https = true;
        nginx.recommendedHttpHeaders = true;
        hostName = cfg.domain;

        home = "/srv/storage/nextcloud";
        maxUploadSize = "4G";
        enableImagemagick = true;

        caching = {
          apcu = true;
          memcached = true;
          redis = true;
        };

        extraApps = with config.services.nextcloud.package.packages.apps; {
          inherit contacts calendar;
        };

        autoUpdateApps = {
          enable = true;
          startAt = "02:00";
        };

        config = {
          adminuser = "isabel";
          adminpassFile = config.age.secrets.nextcloud-passwd.path;

          # database
          dbtype = "pgsql";
          dbhost = "/run/postgresql";
          dbname = "nextcloud";
        };

        settings = {
          defaultPhoneRegion = "UK";

          overwriteProtocol = "https";
          extraTrustedDomains = [ "https://${toString cfg.domain}" ];
          trustedProxies = [ "https://${toString cfg.domain}" ];

          redis = {
            host = "/run/redis-nextcloud/redis.sock";
            dbindex = 0;
            timeout = 1.5;
          };
        };

        phpOptions = {
          # fix the opcache "buffer is almost full" error in admin overview
          "opcache.interned_strings_buffer" = "16";
        };
      };

      nginx.virtualHosts.${cfg.domain} = template.ssl rdomain;
    };

    systemd.services = {
      phpfpm-nextcloud.aliases = [ "nextcloud.service" ];

      "nextcloud-setup" = {
        requires = [ "postgresql.service" ];
        after = [ "postgresql.service" ];
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "10s";
        };
      };
    };
  };
}
