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
  config = mkIf cfg.kanidm.enable {
    modules.services.database = {
      postgresql.enable = true;
    };

    services = {
      plausible = {
        enable = true;

        port = 2100;
        baseUrl = "https://${plausible_domain}";

        server.disableRegistration = true;

        adminUser = {
          activate = true;
          name = "isabel";
          email = "isabel@${domain}";
          passwordFile = config.sops.secrets.plausible-admin;
        };

        database.postgres = {
          dbname = "plausible";
          socket = "/run/postgresql";
        };
      };

      nginx.virtualHosts.${plausible_domain} =
        {
          locations."/".proxyPass = "https://${config.services.plausible.port}";
        }
        // lib.template.ssl domain;
    };
  };
}
