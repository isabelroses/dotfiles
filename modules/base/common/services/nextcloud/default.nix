{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.networking) domain;
  nextcloud_domain = "cloud.${domain}";

  inherit (lib) mkIf sslTemplate;

  cfg = config.modules.services;
in {
  config = mkIf cfg.nextcloud.enable {
    modules.services.database = {
      redis.enable = true;
      postgresql.enable = true;
    };

    services = {
      nextcloud = {
        enable = true;
        package = pkgs.nextcloud27;

        # webs stuff
        https = true;
        nginx.recommendedHttpHeaders = true;
        hostName = nextcloud_domain;

        home = "/srv/storage/nextcloud";
        maxUploadSize = "4G";
        enableImagemagick = true;

        caching = {
          apcu = true;
          memcached = true;
          redis = true;
        };

        extraOptions = {
          redis = {
            host = "/run/redis-default/redis.sock";
            dbindex = 0;
            timeout = 1.5;
          };
        };

        extraApps = with config.services.nextcloud.package.packages.apps; {
          inherit news contacts calendar;
        };

        autoUpdateApps = {
          enable = true;
          startAt = "02:00";
        };

        config = {
          overwriteProtocol = "https";
          extraTrustedDomains = ["https://${toString nextcloud_domain}"];
          trustedProxies = ["https://${toString nextcloud_domain}"];

          adminuser = "isabel";
          adminpassFile = config.sops.secrets.nextcloud-passwd.path;
          defaultPhoneRegion = "UK";

          # database
          dbtype = "pgsql";
          dbhost = "/run/postgresql";
          dbname = "nextcloud";
        };

        phpOptions = {
          # fix the opcache "buffer is almost full" error in admin overview
          "opcache.interned_strings_buffer" = "16";
        };
      };

      nginx.virtualHosts.${nextcloud_domain} = sslTemplate;
    };

    systemd.services = {
      phpfpm-nextcloud.aliases = ["nextcloud.service"];
      "nextcloud-setup" = {
        requires = ["postgresql.service"];
        after = ["postgresql.service"];
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "10s";
        };
      };
    };
  };
}
