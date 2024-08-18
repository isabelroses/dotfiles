{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.services) mkServiceOption;

  cfg = config.garden.services;
in
{
  options.garden.services.redis = mkServiceOption "redis" { };

  config = mkIf cfg.redis.enable {
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

        # vikunja = mkIf cfg.vikunja.enable {
        #   enable = true;
        #   user = "vikunja";
        #   port = 6372;
        # };
      };
    };
  };
}
