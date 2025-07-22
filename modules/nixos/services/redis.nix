{
  lib,
  pkgs,
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
      package = pkgs.valkey;

      servers = mkMerge [
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
      ];
    };
  };
}
