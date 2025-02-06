{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf mkMerge;
  inherit (self.lib.services) mkServiceOption;

  cfg = config.garden.services;
in
{
  options.garden.services.redis = mkServiceOption "redis" { };

  config = mkIf cfg.redis.enable {
    services.redis = {
      vmOverCommit = true;
      servers = mkMerge [
        (mkIf cfg.nextcloud.enable {
          nextcloud = {
            enable = true;
            user = "nextcloud";
            port = 0;
          };
        })

        (mkIf cfg.forgejo.enable {
          forgejo = {
            enable = true;
            user = "forgejo";
            port = 6371;
            databases = 16;
            logLevel = "debug";
            requirePass = "forgejo";
          };
        })

        # (mkIf cfg.vikunja.enable {
        #   vikunja = {
        #     enable = true;
        #     user = "vikunja";
        #     port = 6372;
        #   };
        # })
      ];
    };
  };
}
