{
  lib,
  pkgs,
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

        package = pkgs.pds.overrideAttrs (
          finalAttrs: oa: {
            version = "0.4.169";

            src = pkgs.fetchFromGitHub {
              owner = "bluesky-social";
              repo = "pds";
              tag = "v${finalAttrs.version}";
              hash = "sha256-CInfhE9PeAbScVtMvvEyA5f6q0WIChTHf49/vh+Kqwc=";
            };

            pnpmDeps = pkgs.pnpm_9.fetchDeps {
              inherit (finalAttrs)
                pname
                version
                src
                sourceRoot
                ;
              fetcherVersion = 1;
              hash = "sha256-bBGumJBpTWaSPpo4WUNvdF2PCOS6w60Xn6kgS12y6PU=";
            };
          }
        );

        environmentFiles = [ config.sops.secrets.pds-env.path ];

        settings = {
          PDS_PORT = cfg.port;
          PDS_HOSTNAME = cfg.domain;
          PDS_CRAWLERS = "https://bsky.network,https://relay.cerulea.blue";
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            proxyWebsockets = true;
          };

          # https://gist.github.com/mary-ext/6e27b24a83838202908808ad528b3318
          "/xrpc/app.bsky.unspecced.getAgeAssuranceState" =
            let
              state = builtins.toJSON {
                lastInitiatedAt = "2025-07-14T15:11:05.487Z";
                status = "assured";
              };
            in
            {
              return = "200 '${state}'";
              extraConfig = ''
                add_header access-control-allow-headers "authorization,dpop,atproto-accept-labelers,atproto-proxy" always;
                add_header access-control-allow-origin "*" always;
                add_header X-Frame-Options SAMEORIGIN always;
                add_header X-Content-Type-Options nosniff;
                default_type application/json;
              '';
            };
        };
      };
    };
  };
}
