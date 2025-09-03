{
  lib,
  self,
  config,
  inputs',
  ...
}:
let
  cfg = config.garden.services.pds;

  inherit (lib) mkIf concatStringsSep;
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
      bluesky-pds = {
        enable = true;
        pdsadmin.enable = true;

        environmentFiles = [ config.sops.secrets.pds-env.path ];

        settings = {
          PDS_PORT = cfg.port;
          PDS_HOSTNAME = cfg.domain;

          # crawlers taken from the following post
          # <https://bsky.app/profile/billy.wales/post/3lxpd67hnks2e>
          PDS_CRAWLERS = concatStringsSep "," [
            "https://bsky.network"
            "https://relay.cerulea.blue"
            "https://relay.fire.hose.cam"
            "https://relay2.fire.hose.cam"
            "https://relay3.fr.hose.cam"
            "https://relay.hayescmd.net"
          ];

          PDS_OAUTH_PROVIDER_NAME = "tgirl.cloud";
          PDS_OAUTH_PROVIDER_LOGO = "https://cdn.bsky.app/img/avatar/plain/did:plc:msjw2c6vob56zkr3zx7nt6wc/bafkreih52fl3otjhihb5gb5uvsbtctck62qut3e5ex43twrgg7uqgfos5m@jpeg";
          PDS_OAUTH_PROVIDER_PRIMARY_COLOR = "#86DCE9";
          PDS_OAUTH_PROVIDER_ERROR_COLOR = "#F6598E";
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations = {
          # setup and serve our pds dashboard
          "= /" = {
            root = inputs'.tgirlpkgs.packages.pds-dash;
            index = "index.html";
          };
          "= /index.html".root = inputs'.tgirlpkgs.packages.pds-dash;
          "/assets".root = inputs'.tgirlpkgs.packages.pds-dash;

          # pass everything else to the pds
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
