{
  lib,
  self,
  config,
  ...
}:
let
  inherit (self.lib) template;
  inherit (lib.modules) mkIf;
  inherit (self.lib.services) mkServiceOption;
  inherit (self.lib.secrets) mkSecret;

  rdomain = config.networking.domain;
  cfg = config.garden.services.plausible;
in
{
  options.garden.services.plausible = mkServiceOption "plausible" {
    port = 2100;
    domain = "p.${rdomain}";
  };

  config = mkIf cfg.enable {
    age.secrets = {
      plausible-key = mkSecret {
        file = "plausible/key";
        owner = "plausible";
        group = "plausible";
      };

      plausible-admin = mkSecret {
        file = "plausible/admin";
        owner = "plausible";
        group = "plausible";
      };
    };

    garden.services.postgresql.enable = true;

    services = {
      plausible = {
        enable = true;

        server = {
          inherit (cfg) port;
          baseUrl = "https://${cfg.domain}";

          disableRegistration = true;
          secretKeybaseFile = config.age.secrets.plausible-key.path;
        };

        adminUser = {
          activate = true;
          name = "isabel";
          email = "isabel@${cfg.domain}";
          passwordFile = config.age.secrets.plausible-admin.path;
        };

        database.postgres = {
          dbname = "plausible";
          socket = "/run/postgresql";
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/".proxyPass = "http://${cfg.host}:${toString cfg.port}";
      } // template.ssl rdomain;
    };

    users = {
      groups.plausible = { };

      users.plausible = {
        group = "plausible";
        createHome = false;
        isSystemUser = true;
      };
    };
  };
}
