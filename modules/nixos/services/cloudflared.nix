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
    age.secrets.cloudflared-athena = mkSystemSecret {
      file = "cloudflare/athena";
    };

    networking = { inherit (cfg) domain; };

    services.cloudflared = {
      enable = true;

      tunnels.${config.networking.hostName} = {
        credentialsFile = config.age.secrets.cloudflared-athena.path;
        default = "http_status:404";
      };
    };
  };
}
