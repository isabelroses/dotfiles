{
  lib,
  self,
  config,
  ...
}:
let
  inherit (self.lib) mkService;
  inherit (lib.modules) mkIf;

  cfg = config.garden.services.quoteit;
in
{
  imports = [
    (mkService "quoteit" {
      port = 3018;
      domain = "evilbel.org";
    })
  ];

  config = mkIf cfg.enable {
    services = {
      quoteit = {
        enable = true;
        inherit (cfg) port;
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/".proxyPass = "http://${cfg.host}:${toString cfg.port}";
      };
    };
  };
}
