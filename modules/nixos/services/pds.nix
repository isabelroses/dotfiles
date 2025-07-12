{
  lib,
  self,
  config,
  ...
}:
let
  cfg = config.garden.services.pds;

  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption mkSystemSecret;
in
{
  options.garden.services.pds = mkServiceOption "pds" {
    port = 3601;
    domain = "pds.tgirl.cloud";
  };

  config = mkIf cfg.enable {
    sops.secrets.pds-env = mkSystemSecret {
      file = "pds";
      owner = "pds";
      group = "pds";
    };

    services = {
      pds = {
        enable = true;
        pdsadmin.enable = true;

        environmentFiles = [
          config.sops.secrets.pds-env.path
        ];

        settings = {
          PDS_PORT = cfg.port;
          PDS_HOSTNAME = cfg.domain;
          PDS_CRAWLERS = "https://bsky.network,https://relay.cerulea.blue";
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
