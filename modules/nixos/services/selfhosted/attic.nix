{
  lib,
  pkgs,
  self,
  config,
  ...
}:
let
  inherit (self.lib) template;
  inherit (lib.modules) mkIf;
  inherit (self.lib.services) mkServiceOption;
  inherit (self.lib.secrets) mkSecret;

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
    age.secrets = {
      attic-env = mkSecret {
        file = "attic/env";
        owner = "atticd";
      };
      attic-prod-auth-token = mkSecret { file = "attic/prod-auth-token"; };
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
            client_max_body_size 50m;
          '';
        };
      } // template.ssl rdomain;
    };

    # Add netrc file for this machine to do its normal thing with the cache, as a machine.
    # nix.settings.netrc-file = config.age.secrets."attic/netrc-file-pull-push".path;

    systemd.services.attic-watch-store = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      environment.HOME = "/var/lib/attic-watch-store";
      serviceConfig = {
        DynamicUser = true;
        MemoryHigh = "5%";
        MemoryMax = "10%";
        LoadCredential = "prod-auth-token:${config.age.secrets.attic-prod-auth-token.path}";
        StateDirectory = "attic-watch-store";
      };
      path = [ pkgs.attic-client ];
      script = ''
        set -eux -o pipefail
        ATTIC_TOKEN=$(< $CREDENTIALS_DIRECTORY/prod-auth-token)
        attic login prod https://${cfg.domain} $ATTIC_TOKEN
        attic use prod
        exec attic watch-store prod:prod
      '';
    };
  };
}
