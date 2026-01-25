{
  lib,
  self,
  config,
  ...
}:
let
  cfg = config.garden.services.glance;
  rdomain = config.networking.domain;

  inherit (lib) mkIf flip;
  inherit (self.lib) mkServiceOption mkSecret;
  glanceLib = import ./lib.nix lib;

  srv = config.garden.services;
in
{
  options.garden.services.glance = mkServiceOption "glance" {
    port = 3028;
    host = "0.0.0.0";
    domain = "dash.${rdomain}";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      glance-key = mkSecret {
        file = "glance";
        key = "secret-key";
      };

      glance-isabel-pass = mkSecret {
        file = "glance";
        key = "isabel-password";
      };

      glance-env = mkSecret {
        file = "glance";
        key = "env";
      };
    };

    services = {
      glance = {
        enable = true;
        environmentFile = config.sops.secrets.glance-env.path;

        settings = {
          auth = {
            secret-key = {
              _secret = config.sops.secrets.glance-key.path;
            };
            users.isabel.password = {
              _secret = config.sops.secrets.glance-isabel-pass.path;
            };
          };

          server = {
            proxied = true;
            inherit (cfg) port host;
          };

          theme = {
            background-color = "240 21 15";
            contrast-multiplier = 1.2;
            primary-color = "217 92 83";
            positive-color = "115 54 76";
            negative-color = "347 70 65";
          };

          branding.hide-footer = true;

          pages = map (flip import { inherit lib srv glanceLib; }) [
            ./home.nix
            ./news.nix
            ./reads.nix
          ];
        };
      };

      cloudflared.tunnels.${config.networking.hostName} = {
        ingress.${cfg.domain} = "http://${cfg.host}:${toString cfg.port}";
      };
    };
  };
}
