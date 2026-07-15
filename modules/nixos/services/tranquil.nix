{
  lib,
  self,
  config,
  ...
}:
let
  cfg = config.garden.services.tranquil;

  inherit (lib.modules) mkIf;
  inherit (self.lib) mkServiceOption mkSecret;
in
{
  options.garden.services.tranquil = mkServiceOption "tranquil" {
    port = 3032;
    domain = "pds.isabelroses.com";
  };

  config = mkIf cfg.enable {
    sops.secrets.tranquil-env = mkSecret {
      file = "tranquil";
      key = "env";
    };

    services = {
      tranquil-pds = {
        enable = true;
        database.createLocally = true;

        environmentFiles = [ config.sops.secrets.tranquil-env.path ];

        settings = {
          server = {
            inherit (cfg) port;
            hostname = cfg.domain;
            invite_code_required = true;
            age_assurance_override = true;
          };

          # crawlers shamlessly stolen from
          # <https://compare.hose.cam>
          firehose.crawlers = [
            "https://bsky.network"
            "https://atproto.africa"
            "https://relay1.us-east.bsky.network"
            "https://relay.fire.hose.cam"
            "https://relay3.fr.hose.cam"
            "https://relay.feeds.blue"
          ];
        };
      };

      nginx.virtualHosts.${cfg.domain}.locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
        extraConfig = "client_max_body_size ${toString config.services.tranquil-pds.settings.server.max_blob_size};";
      };
    };
  };
}
