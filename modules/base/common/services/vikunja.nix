{
  config,
  lib,
  ...
}: let
  inherit (config.networking) domain;

  cfg = config.modules.services.vikunja;

  inherit (lib) mkIf;
in {
  config = mkIf cfg.enable {
    modules.services.database = {
      postgresql.enable = true;
    };

    services = {
      vikunja = {
        enable = true;
        setupNginx = true;
        frontendHostname = "todo.${domain}";
        frontendScheme = "https";

        database = {
          type = "postgres";
          host = "/run/postgresql";
          user = "vikunja";
          database = "vikunja";
        };

        # settings = {};
      };
    };
  };
}
