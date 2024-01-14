{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  rdomain = config.networking.domain;
  cfg = config.modules.services.networking.cloudflared;
in {
  services.cloudflared = mkIf cfg.enable {
    enable = true;

    tunnels.${config.networking.hostName} = {
      credentialsFile = "${config.sops.secrets.cloudflared-hydra.path}";
      default = "http_status:404";

      # example of jellyfin
      ingress = {
        "tv.${rdomain}" = "http://${cfg.host}:8096";
      };
    };
  };
}
