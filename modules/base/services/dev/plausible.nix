{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf template;

  rdomain = config.networking.domain;
  cfg = config.modules.services.dev.plausible;
in {
  config = mkIf cfg.enable {
    modules.services.database = {
      postgresql.enable = true;
    };

    services = {
      plausible = {
        enable = true;

        server = {
          inherit (cfg) port;
          baseUrl = "https://${cfg.domain}";

          disableRegistration = true;
          secretKeybaseFile = config.sops.secrets.plausible-key.path;
        };

        adminUser = {
          activate = true;
          name = "isabel";
          email = "isabel@${cfg.domain}";
          passwordFile = config.sops.secrets.plausible-admin.path;
        };

        database.postgres = {
          dbname = "plausible";
          socket = "/run/postgresql";
        };
      };

      nginx.virtualHosts.${cfg.domain} =
        {
          locations."/".proxyPass = "http://${cfg.host}:${toString cfg.port}";
        }
        // template.ssl rdomain;
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
