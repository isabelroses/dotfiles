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
  config = mkIf ((builtins.elem dev.type acceptedTypes) && cfg.database.mysql.enable) {
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
