{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.services) mkServiceOption;

  cfg = config.garden.services;
in
{
  options.garden.services.database.redis = mkServiceOption "redis" { };

  config = mkIf cfg.database.redis.enable {
    services.redis = {
      vmOverCommit = true;
      servers = {
        nextcloud = mkIf cfg.media.nextcloud.enable {
          enable = true;
          user = "nextcloud";
          port = 0;
        };

        forgejo = mkIf cfg.dev.forgejo.enable {
          enable = true;
          user = "forgejo";
          port = 6371;
          databases = 16;
          logLevel = "debug";
          requirePass = "forgejo";
        };

        # vikunja = mkIf cfg.vikunja.enable {
        #   enable = true;
        #   user = "vikunja";
        #   port = 6372;
        # };
      };
    };
  };
}
