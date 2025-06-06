{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.services) mkServiceOption;

  rdomain = config.networking.domain;
  cfg = config.garden.services.atuin;
in
{
  options.garden.services.atuin = mkServiceOption "atuin" {
    port = 43473;
    domain = "atuin.${rdomain}";
  };

  config = mkIf cfg.enable {
    garden.services = {
      postgresql.enable = true;
    };

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
