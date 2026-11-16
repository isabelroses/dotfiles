{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib) mkSecret mkService;

  cfg = config.garden.services.piper;
in
{
  imports = [
    (mkService "piper" {
      port = 3015;
      domain = "piper.kittysay.xyz";
    })
  ];

  config = mkIf cfg.enable {
    sops.secrets = {
      piper = mkSecret {
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
          SERVER_HOST = cfg.host;
          SERVER_PORT = cfg.port;
          SERVER_ROOT_URL = "https://${cfg.domain}";
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/".proxyPass = "http://${cfg.host}:${toString cfg.port}";
      };
    };
  };
}
