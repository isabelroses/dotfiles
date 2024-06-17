{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkServiceOption;

  cfg = config.modules.services.database.mysql;
in
{
  options.modules.services.database.mysql = mkServiceOption "mysql" { };

  config = mkIf cfg.enable {
    services.mysql = {
      enable = true;
      package = pkgs.mariadb;

      # databases and users
      ensureDatabases = [ "mkm" ];
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
