{ lib, config, ... }:
let
  inherit (lib) mkIf;
  cfg = config.modules.services.media.jellyfin;
in
{
  services.jellyfin = mkIf cfg.enable {
    enable = true;
    group = "jellyfin";
    user = "jellyfin";
    openFirewall = true;
  };
}
