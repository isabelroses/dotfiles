{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption;

  cfg = config.garden.services.sonarr;
in
{
  options.garden.services.sonarr = mkServiceOption "sonarr" {
    port = 3020;
  };

  config = mkIf config.garden.services.sonarr.enable {
    services.sonarr = {
      inherit (cfg) enable;
      group = "media";
      dataDir = "/srv/storage/sonarr";
      openFirewall = true;

      settings.server.port = cfg.port;
    };
  };
}
