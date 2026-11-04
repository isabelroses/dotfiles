{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib) mkServiceOption mkSecret;

  cfg = config.garden.services.blahaj;
in
{
  options.garden.services.blahaj = mkServiceOption "blahaj" {
    # blahaj's module has no port option, it always listens on 3000
    port = 3000;
    domain = "blahaj.isabelroses.com";
  };

  config = mkIf cfg.enable {
    sops.secrets.blahaj-env = mkSecret {
      file = "blahaj";
      key = "env";
    };

    services = {
      blahaj = {
        enable = true;
        environmentFile = config.sops.secrets.blahaj-env.path;
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/".proxyPass = "http://${cfg.host}:${toString cfg.port}";
      };
    };
  };
}
