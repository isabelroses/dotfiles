{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (config.networking) domain;
in {
  services.cloudflared = mkIf (config.modules.usrEnv.services.cloudflared.enable) {
    enable = true;
    tunnels.${config.networking.hostName} = {
      credentialsFile = "${config.sops.secrets.cloudflared-hydra.path}";
      default = "http_status:404";
      ingress = {
        "tv.${domain}" = "http://localhost:8096";
      };
    };
  };
}
