{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.modules.services.networking.cloudflared;
in {
  users.users.cloudflared = {
    description = "Cloudflared user";
    home = "/var/lib/cloudflared";
    isSystemUser = true;
    createHome = true;
  };

  services.cloudflared = mkIf cfg.enable {
    enable = true;

    tunnels.${config.networking.hostName} = {
      credentialsFile = config.age.secrets.cloudflared-hydra.path;
      default = "http_status:404";

      # example of jellyfin
      ingress = {
        # "tv.${rdomain}" = "http://${cfg.host}:8096";
        "ctp-wiki.${cfg.domain}".service = "http://${cfg.host}:80";
      };
    };
  };
}
