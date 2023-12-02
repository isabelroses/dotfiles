{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.modules.services;
in {
  config = mkIf cfg.database.redis.enable {
    services.redis = {
      vmOverCommit = true;
      servers = {
        nextcloud = mkIf cfg.nextcloud.enable {
          enable = true;
          user = "nextcloud";
          port = 0;
        };

        forgejo = mkIf cfg.forgejo.enable {
          enable = true;
          user = "forgejo";
          port = 6371;
          databases = 16;
          logLevel = "debug";
          requirePass = "forgejo";
        };

        searxng = mkIf cfg.searxng.enable {
          enable = true;
          user = "searx";
          port = 6370;
          databases = 16;
          logLevel = "debug";
          requirePass = "searxng";
        };
      };
    };
  };
}
