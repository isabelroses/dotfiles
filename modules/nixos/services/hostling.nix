{
  lib,
  self,
  config,
  inputs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption mkSecret;

  cfg = config.garden.services.hostling;
in
{
  options.garden.services.hostling = mkServiceOption "hostling" {
    port = 3025;
    host = "127.0.0.1";
    domain = "cdn.${config.networking.domain}";
  };

  imports = [ inputs.hostling.nixosModules.default ];

  config = mkIf cfg.enable {
    sops.secrets.hostling = mkSecret {
      file = "hostling";
      key = "env";
    };

    services = {
      hostling = {
        enable = true;
        createDbLocally = true;

        environmentFile = config.sops.secrets.hostling.path;

        settings = {
          inherit (cfg) port;
          behind_reverse_proxy = true;
          trusted_proxy = cfg.host;
          public_url = "https://${cfg.domain}";

          s3 = {
            bucket = "isa-cdn";
            region = "europe-1";
            endpoint = "in64u.upcloudobjects.com";
            proxyfiles = true;
          };
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/" = {
          proxyPass = "http://${cfg.host}:${toString cfg.port}";
          extraConfig = ''
            client_max_body_size 1G;
          '';
        };
      };
    };
  };
}
