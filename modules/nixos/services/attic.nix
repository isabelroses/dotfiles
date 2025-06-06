{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption mkSystemSecret;

  rdomain = config.networking.domain;

  cfg = config.garden.services.attic;
in
{
  options.garden.services.attic = mkServiceOption "attic" {
    domain = "cache.${rdomain}";
    host = "[::]";
    port = 8080;
  };

  config = mkIf config.garden.services.attic.enable {
    age.secrets.attic-env = mkSystemSecret {
      file = "attic/env";
      owner = "atticd";
    };

    services = {
      atticd = {
        enable = true;
        environmentFile = config.age.secrets.attic-env.path;

        settings = {
          listen = "${cfg.host}:${toString cfg.port}";

          storage = {
            bucket = "meower";
            type = "s3";
            region = "auto";
            endpoint = "https://604a41ff5d2574939efbb1c55bac090e.r2.cloudflarestorage.com";
          };

          chunking = {
            nar-size-threshold = 65536;
            min-size = 16384;
            avg-size = 65536;
            max-size = 262144;
          };

          compression = {
            type = "zstd";
            level = 12;
          };

          garbage-collection.interval = "8 hours";
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/" = {
          proxyPass = "http://${cfg.host}:${toString cfg.port}";
          extraConfig = ''
            client_max_body_size 512m;
          '';
        };
      };
    };
  };
}
