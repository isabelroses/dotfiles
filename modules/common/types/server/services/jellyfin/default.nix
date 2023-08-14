{
  config,
  lib,
  ...
}:
with lib; let
  device = config.modules.device;
  cfg = config.modules.services;
  acceptedTypes = ["server" "hybrid"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes && cfg.jellyfin.enable && cfg.jellyfin.asDockerContainer) {
    modules.system.virtualization = {
      enable = true;
      docker.enable = true;
    };

    virtualisation.oci-containers.containers.jellyfin = {
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
