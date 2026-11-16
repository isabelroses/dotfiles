{
  lib,
  self,
  config,
  ...
}:
let
  inherit (self.lib) mkService;
  inherit (lib.modules) mkIf;

  rdomain = config.networking.domain;
  cfg = config.garden.services.atuin;
in
{
  imports = [
    (mkService "atuin" {
      port = 3004;
      domain = "atuin.${rdomain}";
    })
  ];

  config = mkIf cfg.enable {
    services = {
      atuin = {
        enable = true;
        inherit (cfg) port host;
        openRegistration = false;
        maxHistoryLength = 1024 * 16;
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/".proxyPass = "http://${cfg.host}:${toString cfg.port}";
      };
    };
  };
}
