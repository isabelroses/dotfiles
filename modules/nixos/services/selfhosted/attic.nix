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

  cfg = config.garden.services.attic;
  rdomain = config.networking.domain;
in
{
  options.garden.services.attic = mkServiceOption "attic" { domain = "cache.${rdomain}"; };

  config = mkIf config.garden.services.attic.enable {
    age.secrets.attic-env = mkSecret { file = "attic/env"; };

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
            endpoint = "https://604a41ff5d2574939efbb1c55bac090e.eu.r2.cloudflarestorage.com/meower";
          };

          garbage-collection.interval = "0";
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/" = {
          proxyPass = "http://${cfg.host}:${toString cfg.port}";
        };
      } // template.ssl rdomain;
    };

    # Add netrc file for this machine to do its normal thing with the cache, as a machine.
    # nix.settings.netrc-file = config.age.secrets."attic/netrc-file-pull-push".path;

    # systemd.services.attic-watch-store = {
    #   wantedBy = [ "multi-user.target" ];
    #   after = [ "network-online.target" ];
    #   environment.HOME = "/var/lib/attic-watch-store";
    #   serviceConfig = {
    #     DynamicUser = true;
    #     MemoryHigh = "5%";
    #     MemoryMax = "10%";
    #     LoadCredential = "prod-auth-token:${config.age.secrets."attic/prod-auth-token".path}";
    #     StateDirectory = "attic-watch-store";
    #   };
    #   path = [ pkgs.attic-client ];
    #   script = ''
    #     set -eux -o pipefail
    #     ATTIC_TOKEN=$(< $CREDENTIALS_DIRECTORY/prod-auth-token)
    #     # Replace https://cache.<domain> with your own cache URL.
    #     attic login prod https://cache.<domain> $ATTIC_TOKEN
    #     attic use prod
    #     exec attic watch-store prod:prod
    #   '';
    # };
  };
}
