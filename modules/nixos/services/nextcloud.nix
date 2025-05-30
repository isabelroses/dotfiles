{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  rdomain = config.networking.domain;

  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption mkSystemSecret;

  cfg = config.garden.services.nextcloud;
in
{
  options.garden.services.nextcloud = mkServiceOption "nextcloud" { domain = "cloud.${rdomain}"; };

  config = mkIf cfg.enable {
    age.secrets.nextcloud-passwd = mkSystemSecret {
      file = "nextcloud-passwd";
      owner = "nextcloud";
      group = "nextcloud";
    };

    garden.services = {
      redis.enable = true;
      postgresql.enable = true;

      nginx.vhosts.${cfg.domain} = { };
    };

    services.nextcloud = {
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

      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps) contacts calendar;
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

      # fix the opcache "buffer is almost full" error in admin overview
      phpOptions."opcache.interned_strings_buffer" = "16";
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
