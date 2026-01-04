{
  lib,
  pkgs,
  self,
  config,
  ...
}:
let
  cfg = config.garden.services.pds;
  gkCfg = config.garden.services.pds-gatekeeper;

  inherit (lib) mkIf concatStringsSep;
  inherit (self.lib) mkServiceOption mkSecret;
in
{
  options.garden.services = {
    pds = mkServiceOption "pds" {
      port = 3001;
      domain = "pds.tgirl.cloud";
    };

    pds-gatekeeper = mkServiceOption "pds-gatekeeper" {
      port = 3002;
    };

    pds-dash = mkServiceOption "pds-dash" {
      port = 3014;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      pds-env = mkSecret {
        file = "pds";
        owner = "pds";
        group = "pds";
      };

      pds-dash = mkSecret { file = "pds"; };
    };

    services = {
      bluesky-pds = {
        enable = true;
        pdsadmin.enable = true;

        package = pkgs.bluesky-pds.overrideAttrs (
          finalAttrs: _: {
            src = pkgs.fetchFromGitHub {
              owner = "isabelroses";
              repo = "pds-fork";
              rev = "66c026acfcfd290ea962dd4d03379f0990d80071";
              hash = "sha256-x+oh3YKcz2eWkAqg+jZKrh35UoGI6dLQXcEiGItTHKc=";
            };

            pnpmDeps = pkgs.fetchPnpmDeps {
              inherit (finalAttrs)
                pname
                version
                src
                sourceRoot
                ;
              pnpm = pkgs.pnpm_9;
              fetcherVersion = 2;
              hash = "sha256-4qKWkINpUHzatiMa7ZNYp1NauU2641W0jHDjmRL9ipI=";
            };
          }
        );

        environmentFiles = [ config.sops.secrets.pds-env.path ];

        settings = {
          PDS_PORT = cfg.port;
          PDS_HOSTNAME = cfg.domain;

          # damn scrapers vro
          PDS_ADMIN_EMAIL = "isabel" + "@" + "isabelroses" + "." + "com";

          # crawlers shamlessly stolen from
          # <https://compare.hose.cam>
          PDS_CRAWLERS = concatStringsSep "," [
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

          PDS_OAUTH_PROVIDER_NAME = "tgirl.cloud";
          PDS_OAUTH_PROVIDER_LOGO = "https://cdn.bsky.app/img/avatar/plain/did:plc:msjw2c6vob56zkr3zx7nt6wc/bafkreih52fl3otjhihb5gb5uvsbtctck62qut3e5ex43twrgg7uqgfos5m@jpeg";
          PDS_OAUTH_PROVIDER_PRIMARY_COLOR = "#86DCE9";
          PDS_OAUTH_PROVIDER_ERROR_COLOR = "#F6598E";

          PDS_SERVICE_HANDLE_DOMAINS = ".tgirl.beauty";

          # custom session duration: 30 days
          PDS_OAUTH_AUTHENTICATION_MAX_AGE = "2592000000";
        };
      };

      pds-dash = {
        enable = true;
        setupNginx = true;

        environmentFiles = [ config.sops.secrets.pds-dash.path ];

        settings = {
          PORT = config.garden.services.pds-dash.port;
          LOCATION = config.sops.secrets.pds-env.path;
        };
      };

      pds-gatekeeper = {
        enable = true;
        setupNginx = true;

        settings = {
          GATEKEEPER_PORT = gkCfg.port;
          PDS_BASE_URL = "http://${cfg.host}:${toString cfg.port}";
          GATEKEEPER_TRUST_PROXY = "true";

          GATEKEEPER_EMAIL_TEMPLATES_DIRECTORY = toString (
            pkgs.runCommandLocal "pds-email-templates" { } ''
              mkdir -p $out
              cp ${./two_factor_code.hbs} $out/two_factor_code.hbs
            ''
          );

          # we need to share a lot of secrets between pds and gatekeeper
          PDS_ENV_LOCATION = config.sops.secrets.pds-env.path;
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        serverAliases = [ ".tgirl.beauty" ];
        enableACME = true;

        locations =
          let
            mkAgeAssured = state: {
              return = "200 '${builtins.toJSON state}'";
              extraConfig = ''
                add_header access-control-allow-headers "authorization,dpop,atproto-accept-labelers,atproto-proxy" always;
                add_header access-control-allow-origin "*" always;
                add_header X-Frame-Options SAMEORIGIN always;
                add_header X-Content-Type-Options nosniff;
                default_type application/json;
              '';
            };
          in
          {
            # i am of age but i don't want to prove it lol
            # https://gist.github.com/mary-ext/6e27b24a83838202908808ad528b3318
            "/xrpc/app.bsky.unspecced.getAgeAssuranceState" = mkAgeAssured {
              lastInitiatedAt = "2025-07-14T15:11:05.487Z";
              status = "assured";
            };
            "/xrpc/app.bsky.ageassurance.getConfig" = mkAgeAssured {
              regions = [ ];
            };
            "/xrpc/app.bsky.ageassurance.getState" = mkAgeAssured {
              state = {
                lastInitiatedAt = "2025-07-14T15:11:05.487Z";
                status = "assured";
                access = "full";
              };
              metadata = {
                accountCreatedAt = "2022-11-17T00:35:16.391Z";
              };
            };

            # pass everything else to the pds
            "/" = {
              proxyPass = "http://${cfg.host}:${toString cfg.port}";
              proxyWebsockets = true;
            };
          };
      };
    };
  };
}
