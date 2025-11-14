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

  cfg = config.garden.services.piper;
in
{
  options.garden.services.piper = mkServiceOption "piper" {
    port = 3015;
    domain = "piper.${rdomain}";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      piper = mkSystemSecret {
        file = "piper";
        key = "env";
      };
    };

    services = {
      piper = {
        enable = true;

        environmentFiles = [
          config.sops.secrets.piper.path
        ];

        settings = {
          SERVER_PORT = cfg.port;
          SERVER_ROOT_URL = "https://${cfg.domain}";
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/".proxyPass = "http://localhost:${toString cfg.port}";
      };
    };
  };
}
