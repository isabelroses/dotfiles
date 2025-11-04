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
  inherit (self.lib) mkServiceOption mkSystemSecret;
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
      pds-env = mkSystemSecret {
        file = "pds";
        owner = "pds";
        group = "pds";
      };

      pds-dash = mkSystemSecret { file = "pds"; };
    };

    services = {
      bluesky-pds = {
        enable = true;
        pdsadmin.enable = true;

        environmentFiles = [ config.sops.secrets.pds-env.path ];

        settings = {
          PDS_PORT = cfg.port;
          PDS_HOSTNAME = cfg.domain;

          # damn scrapers vro
          PDS_ADMIN_EMAIL = "isabel" + "@" + "isabelroses" + "." + "com";

          # crawlers taken from the following post
          # <https://bsky.app/profile/billy.wales/post/3lxpd67hnks2e>
          PDS_CRAWLERS = concatStringsSep "," [
            "https://bsky.network"
            "https://relay.cerulea.blue"
            "https://relay.fire.hose.cam"
            "https://relay2.fire.hose.cam"
            "https://relay3.fr.hose.cam"
            "https://relay.hayescmd.net"
            "https://relay.upcloud.world"
          ];

          PDS_OAUTH_PROVIDER_NAME = "tgirl.cloud";
          PDS_OAUTH_PROVIDER_LOGO = "https://cdn.bsky.app/img/avatar/plain/did:plc:msjw2c6vob56zkr3zx7nt6wc/bafkreih52fl3otjhihb5gb5uvsbtctck62qut3e5ex43twrgg7uqgfos5m@jpeg";
          PDS_OAUTH_PROVIDER_PRIMARY_COLOR = "#86DCE9";
          PDS_OAUTH_PROVIDER_ERROR_COLOR = "#F6598E";

          PDS_SERVICE_HANDLE_DOMAINS = ".tgirl.beauty";
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
        serverName = "${cfg.domain} .${cfg.domain} .tgirl.beauty";

        locations = {
          # i am of age but i don't want to prove it lol
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
