{ lib, config, ... }:
let
  inherit (lib) mkIf mkSecret mkServiceOption;

  cfg = config.garden.services.networking.cloudflared;
in
{
  options.garden.services.networking.cloudflared = mkServiceOption "cloudflared" { };

  config = mkIf cfg.enable {
    age.secrets.cloudflared-hydra = mkSecret {
      file = "cloudflare/hydra";
      owner = "cloudflared";
      group = "cloudflared";
    };

    users.groups.cloudflared = { };
    users.users.cloudflared = {
      description = "Cloudflared user";
      home = "/var/lib/cloudflared";
      isSystemUser = true;
      group = "cloudflared";
      createHome = true;
    };

    services.cloudflared = {
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
  };
}
