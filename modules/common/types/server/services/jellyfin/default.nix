{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  device = config.modules.device;
  cfg = config.modules.services.jellyfin;
  acceptedTypes = ["server" "hybrid"];
in { 
  config = mkIf (builtins.elem device.type acceptedTypes && cfg.enable) {
    # NOT docker
    services = mkIf (!cfg.asDockerContainer){
      jellyfin = {
        enable = true;
        group = "jellyfin";
        user = "jellyfin";
        openFirewall = true;
      };
    };

    # with docker
    modules.system.virtualization = mkIf (cfg.asDockerContainer) {
      enable = true;
      docker.enable = true;
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
