{
  lib,
  pkgs,
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

        nginx.enable = true;
        database.createLocally = true;

        environmentFiles = [ config.sops.secrets.tranquil-env.path ];

        settings = {
          server = {
            inherit (cfg) port;
            hostname = cfg.domain;
            invite_code_required = true;
            age_assurance_override = true;
          };

          signal.cli_path = pkgs.emptyFile;

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

      nginx.virtualHosts.${cfg.domain}.locations = {
        "/xrpc/".extraConfig = ''
          add_header access-control-allow-headers "authorization,dpop,atproto-accept-labelers,atproto-proxy" always;
          add_header X-Frame-Options SAMEORIGIN always;
          add_header X-Content-Type-Options nosniff;
        '';

        "/assets/".extraConfig = ''
          add_header 'Referrer-Policy' 'origin-when-cross-origin';
          add_header X-Frame-Options "SAMEORIGIN" always;
          add_header X-Content-Type-Options nosniff;
        '';
      };
    };
  };
}
