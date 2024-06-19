{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    template
    mkSecret
    mkServiceOption
    ;

  rdomain = config.networking.domain;
  cfg = config.modules.services.dev.plausible;
in
{
  options.modules.services.dev.plausible = mkServiceOption "plausible" {
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
