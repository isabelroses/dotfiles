{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  inherit (config.networking) domain;
  plausible_domain = "p.${domain}";

  cfg = config.modules.services;
in {
  config = mkIf cfg.plausible.enable {
    modules.services.database = {
      postgresql.enable = true;
    };

    services = {
      plausible = {
        enable = true;

        server = {
          port = 2100;
          baseUrl = "https://${plausible_domain}";

          disableRegistration = true;
          secretKeybaseFile = config.sops.secrets.plausible-key.path;
        };

        adminUser = {
          activate = true;
          name = "isabel";
          email = "isabel@${domain}";
          passwordFile = config.sops.secrets.plausible-admin.path;
        };

        database.postgres = {
          dbname = "plausible";
          socket = "/run/postgresql";
        };
      };

      nginx.virtualHosts.${plausible_domain} =
        {
          locations."/".proxyPass = "http://127.0.0.1:${toString config.services.plausible.server.port}";
        }
        // lib.template.ssl domain;
    };

    users = {
      groups.plausible = {};

      users.plausible = {
        group = "plausible";
        createHome = false;
        isSystemUser = true;
      };
    };
  };
}
