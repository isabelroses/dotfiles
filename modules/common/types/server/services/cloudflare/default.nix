{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
in {
  services.cloudflared = mkIf (config.modules.services.cloudflare.enable) {
    enable = true;
    user = "${config.modules.system.mainUser}";
    tunnels."${config.modules.services.cloudflare.id}" = {
      credentialsFile = "${config.sops.secrets.cloudflared-hydra.path}";
      default = "http_status:404";
      ingress = {
        "tv.isabelroses.com" = "http://localhost:8096";
      };
    };
  };
}
