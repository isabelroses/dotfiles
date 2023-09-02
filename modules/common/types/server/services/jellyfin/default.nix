{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.modules.usrEnv.services.jellyfin;
in {
  config = mkIf cfg.enable {
    # NOT docker
    services = mkIf (!cfg.asDockerContainer) {
      jellyfin = {
        enable = true;
        group = "jellyfin";
        user = "jellyfin";
        openFirewall = true;
      };
    };

    virtualisation.oci-containers.containers.jellyfin = mkIf (cfg.asDockerContainer) {
      image = "lscr.io/linuxserver/jellyfin:latest";
      environment = {
        "PUID" = "1000";
        "PGID" = "1000";
        "TZ" = "Europe/London";
      };
      volumes = [
        "/home/isabel/docker/jellyfin:/config"
        "/mnt/media:/data"
      ];
      ports = ["8096:8096"];
      autoStart = true;
    };
  };
}
