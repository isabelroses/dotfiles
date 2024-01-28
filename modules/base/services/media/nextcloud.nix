{
  config,
  lib,
  pkgs,
  ...
}: let
  rdomain = config.networking.domain;

  inherit (lib) mkIf template;

  cfg = config.modules.services.media.nextcloud;
in {
  config = mkIf cfg.enable {
    modules.services = {
      networking.nginx.enable = true;
      database = {
        redis.enable = true;
        postgresql.enable = true;
      };
    };

    services = {
      nextcloud = {
        enable = true;
        package = pkgs.nextcloud28;

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

        extraOptions = {
          redis = {
            host = "/run/redis-nextcloud/redis.sock";
            dbindex = 0;
            timeout = 1.5;
          };
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
          adminpassFile = config.sops.secrets.nextcloud-passwd.path;

          # database
          dbtype = "pgsql";
          dbhost = "/run/postgresql";
          dbname = "nextcloud";
        };

        extraOptions = {
          defaultPhoneRegion = "UK";

          overwriteProtocol = "https";
          extraTrustedDomains = ["https://${toString cfg.domain}"];
          trustedProxies = ["https://${toString cfg.domain}"];
        };

        phpOptions = {
          # fix the opcache "buffer is almost full" error in admin overview
          "opcache.interned_strings_buffer" = "16";
        };
      };

      nginx.virtualHosts.${cfg.domain} = {http3.enable = true;} // template.ssl rdomain;
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
