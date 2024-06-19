{ lib, config, ... }:
let
  inherit (lib) mkIf mkServiceOption;
  cfg = config.modules.services.media.jellyfin;
in
{
  options.modules.services.media.jellyfin = mkServiceOption "jellyfin" {
    port = 8096;
    domain = "tv.${config.networking.domain}";
  };

  config.services.jellyfin = mkIf cfg.enable {
    enable = true;
    group = "jellyfin";
    user = "jellyfin";
    openFirewall = true;
  };
}
