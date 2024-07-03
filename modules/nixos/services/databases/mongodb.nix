{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkSecret mkServiceOption;

  cfg = config.garden.services.database.mongodb;
in
{
  options.garden.services.database.mongodb = mkServiceOption "mongodb" { host = "0.0.0.0"; };

  config = mkIf cfg.enable {
    age.secrets.mongodb-passwd = mkSecret { file = "mongodb-passwd"; };

    services.mongodb = {
      enable = true;
      package = pkgs.mongodb;
      enableAuth = true;
      initialRootPassword = config.age.secrets.mongodb-passwd.path;
      #bind_ip = cfg.host;
      extraConfig = ''
        operationProfiling.mode: all
      '';
    };
  };
}
