{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.modules.services.media.jellyfin;
in {
  config = mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      group = "jellyfin";
      user = "jellyfin";
      openFirewall = true;
    };
  };
}
