{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (config.networking) domain;
  nextcloud_domain = "cloud.${domain}";

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
        caching.redis = true;
        extraOptions = {
          redis = {
            host = "/run/redis-default/redis.sock";
            dbindex = 0;
            timeout = 1.5;
          };
        };

        hostName = nextcloud_domain;
        home = "/opt/nextcloud";
        maxUploadSize = "4G";
        enableImagemagick = true;

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
        nginx.recommendedHttpHeaders = true;
        https = true;
      };
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
