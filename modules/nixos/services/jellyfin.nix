{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption;

  cfg = config.garden.services.jellyfin;
in
{
  options.garden.services.jellyfin = mkServiceOption "jellyfin" {
    port = 8096;
    domain = "tv.${config.networking.domain}";
  };

  config = mkIf config.garden.services.jellyfin.enable {
    users = {
      groups.media = { };
      users.jellyfin.extraGroups = [
        "video"
        "render"
      ];
    };

    services = {
      jellyfin = {
        enable = true;
        group = "media";
        dataDir = "/srv/storage/jellyfin";
      };

      cloudflared.tunnels.${config.networking.hostName} = {
        ingress.${cfg.domain} = "http://${cfg.host}:${toString cfg.port}";
      };
    };
  };
}
