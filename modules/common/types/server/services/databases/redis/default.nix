{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.modules.services.database.redis;
in {
  config = mkIf cfg.enable {
    services.redis = {
      vmOverCommit = true;
      servers = {
        gitea = mkIf cfg.gitea.enable {
          enable = true;
          user = "gitea";
          port = 6371;
          databases = 16;
          logLevel = "debug";
          requirePass = "gitea";
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
