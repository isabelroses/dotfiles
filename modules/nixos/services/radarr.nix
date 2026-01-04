{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption;

  cfg = config.garden.services.radarr;
in
{
  options.garden.services.radarr = mkServiceOption "radarr" {
    port = 3021;
  };

  config = mkIf config.garden.services.radarr.enable {
    services.radarr = {
      inherit (cfg) enable;
      group = "media";
      dataDir = "/srv/storage/ranarr";
      openFirewall = true;

      settings.server.port = cfg.port;
    };
  };
}
