{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.modules.services.database.mysql;
in {
  config = mkIf cfg.enable {
    services.mysql = {
      enable = true;
      package = pkgs.mariadb;

      # databases and users
      ensureDatabases = ["mkm"];
      ensureUsers = [
        {
          name = "mkm";
          ensurePermissions = {
            "mkm.*" = "ALL PRIVILEGES";
          };
        }
      ];
    };
  };
}
