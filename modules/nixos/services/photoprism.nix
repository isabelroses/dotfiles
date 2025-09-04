{
  lib,
  self,
  config,
  ...
}:
let
  cfg = config.garden.services.photoprism;
  rdomain = config.networking.domain;

  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption mkSystemSecret;
in
{
  options.garden.services.photoprism = mkServiceOption "photoprism" {
    port = 3007;
    domain = "photos.${rdomain}";
  };

  config = mkIf cfg.enable {
    sops.secrets.photoprism-password = mkSystemSecret {
      file = "photoprism";
      key = "password";
    };

    services = {
      photoprism = {
        enable = true;

        inherit (cfg) port;
        address = cfg.host;

        passwordFile = config.sops.secrets.photoprism-password.path;

        originalsPath = "/srv/storage/photoprism/photos";

        settings = {
          PHOTOPRISM_SITE_URL = "https://${cfg.domain}";
          PHOTOPRISM_DISABLE_WEBDAV = "true";
          PHOTOPRISM_APP_NAME = "izphotos";
          PHOTOPRISM_SITE_TITLE = "izphotos";
          PHOTOPRISM_SITE_CAPTION = "goofy goober photos";
          PHOTOPRISM_LEGAL_INFO = "";

          # literally unusable without this
          # it flagged me a few times while setting it up :sob:
          # "maybe you're just that good looking?" - sketch
          PHOTOPRISM_UPLOAD_NSFW = "true";
        };
      };

      cloudflared.tunnels.${config.networking.hostName} = {
        ingress.${cfg.domain} = "http://${cfg.host}:${toString cfg.port}";
      };
    };
  };
}
