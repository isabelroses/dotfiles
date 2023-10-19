{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  dev = config.modules.device;
  cfg = config.modules.services;
  acceptedTypes = ["server" "hybrid"];
in {
  config = mkIf ((builtins.elem dev.type acceptedTypes) && cfg.database.postgresql.enable) {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql;
      dataDir = "/srv/storage/postgresql/${config.services.postgresql.package.psqlSchema}";

      enableTCPIP = false;

      checkConfig = true;
      settings = {
        log_connections = true;
        log_statement = "all";
        logging_collector = true;
        log_disconnections = true;
        log_destination = lib.mkForce "syslog";
      };

      ensureDatabases = [
        "miniflux"
        "gitea"
        "grafana"
        "vaultwarden"
      ];
      ensureUsers = [
        {
          name = "miniflux";
          ensurePermissions."DATABASE miniflux" = "ALL PRIVILEGES";
        }
        {
          name = "postgres";
          ensurePermissions."ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
        }
        {
          name = "gitea";
          ensurePermissions."DATABASE gitea" = "ALL PRIVILEGES";
        }
        {
          name = "grafana";
          ensurePermissions."DATABASE grafana" = "ALL PRIVILEGES";
        }
        {
          name = "vaultwarden";
          ensurePermissions."DATABASE vaultwarden" = "ALL PRIVILEGES";
        }
      ];
    };
  };
}
