{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.services) mkServiceOption;
  inherit (lib.secrets) mkSecret;

  cfg = config.garden.services.mongodb;
in
{
  options.garden.services.mongodb = mkServiceOption "mongodb" { host = "0.0.0.0"; };

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
