# stop forgetting how to do this smh
# <https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/do-more-with-tunnels/local-management/create-local-tunnel/>
{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption mkSecret;

  cfg = config.garden.services.cloudflared;
in
{
  options.garden.services.cloudflared = mkServiceOption "cloudflared" {
    domain = "isabelroses.com";
  };

  config = mkIf cfg.enable {
    sops.secrets.cloudflared-athena = mkSecret {
      file = "cloudflare";
      key = "athena";
    };

    networking = { inherit (cfg) domain; };

    services.cloudflared = {
      enable = true;

      tunnels.${config.networking.hostName} = {
        credentialsFile = config.sops.secrets.cloudflared-athena.path;
        default = "http_status:404";
      };
    };
  };
}
