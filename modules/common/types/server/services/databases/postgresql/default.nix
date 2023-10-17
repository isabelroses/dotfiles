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
      checkConfig = true;
      dataDir = "/srv/storage/postgresql/${config.services.postgresql.package.psqlSchema}";

      ensureDatabases = [
        "miniflux"
      ];
      ensureUsers = [
        {
          name = "miniflux";
          ensurePermissions."DATABASE miniflux" = "ALL PRIVILEGES";
        }
      ];
    };
  };
}
