{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption mkSystemSecret;

  cfg = config.garden.services.cloudflared;
in
{
  options.garden.services.cloudflared = mkServiceOption "cloudflared" { };

  config = mkIf cfg.enable {
    age.secrets.cloudflared-hydra = mkSystemSecret {
      file = "cloudflare/hydra";
      owner = "cloudflared";
      group = "cloudflared";
    };

    users = {
      groups.cloudflared = { };

      users.cloudflared = {
        description = "Cloudflared user";
        home = "/var/lib/cloudflared";
        isSystemUser = true;
        group = "cloudflared";
        createHome = true;
      };
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
