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
  options.garden.services.cloudflared = mkServiceOption "cloudflared" {
    domain = "isabelroses.com";
  };

  config = mkIf cfg.enable {
    sops.secrets.cloudflared-athena = mkSystemSecret {
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
