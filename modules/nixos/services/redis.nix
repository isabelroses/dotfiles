{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (self.lib) mkService;
  inherit (lib.modules) mkIf mkMerge;

  cfg = config.garden.services;
in
{
  # only forgejo's server for now, so it gets the port
  imports = [
    (mkService "redis" { port = 6371; })
  ];

  config = mkIf cfg.redis.enable {
    services.redis = {
      package = pkgs.valkey;

      servers = mkMerge [
        (mkIf cfg.forgejo.enable {
          forgejo = {
            enable = true;
            user = "forgejo";
            inherit (cfg.redis) port;
            bind = cfg.redis.host;
            databases = 16;
            logLevel = "debug";
            requirePass = "forgejo";
          };
        })
      ];
    };
  };
}
