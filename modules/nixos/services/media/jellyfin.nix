{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.services) mkServiceOption;

  cfg = config.garden.services.media.jellyfin;
in
{
  options.garden.services.media.jellyfin = mkServiceOption "jellyfin" {
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
