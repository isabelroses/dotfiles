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
  };

  config = mkIf config.garden.services.blahaj.enable {
    services = {
      quoteit = {
        enable = true;
        inherit (cfg) port;
      };

      nginx.virtualHosts."evilbel.org" = {
        locations."/".proxyPass = "http://127.0.0.1:${toString cfg.port}";
      };
    };
  };
}
