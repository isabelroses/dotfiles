{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkServiceOption;

  cfg = config.garden.services.database.mysql;
in
{
  options.garden.services.database.mysql = mkServiceOption "mysql" { };

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
