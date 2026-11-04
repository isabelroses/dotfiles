{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib) mkServiceOption;

  cfg = config.garden.services.quoteit;
in
{
  options.garden.services.quoteit = mkServiceOption "quoteit" {
    port = 3018;
    domain = "evilbel.org";
  };

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
