{
  lib,
  self,
  config,
  inputs,
  ...
}:
let
  cfg = config.garden.services.tranquil;

  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption mkSecret;
in
{
  options.garden.services.tranquil = mkServiceOption "tranquil" {
    port = 3032;
    domain = "pds.isabelroses.com";
  };

  imports = [ inputs.tranquil.nixosModules.default ];

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
            "https://relay.cerulea.blue"
            "https://relay.fire.hose.cam"
            "https://relay2.fire.hose.cam"
            "https://relay3.fr.hose.cam"
            "https://relay.hayescmd.net"
            "https://relay.xero.systems"
            "https://relay.upcloud.world"
            "https://relay.feeds.blue"
            "https://atproto.africa"
            "https://relay.whey.party"
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
