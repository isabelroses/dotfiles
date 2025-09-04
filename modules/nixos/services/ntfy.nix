{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption;

  rdomain = config.networking.domain;
  cfg = config.garden.services.ntfy;
in
{
  options.garden.services.ntfy = mkServiceOption "nixpkgs-prs-bot" {
    domain = "ntfy.${rdomain}";
    port = 3009;
  };

  config = mkIf cfg.enable {
    services = {
      ntfy-sh = {
        enable = true;
        settings = {
          base-url = "https://${cfg.domain}";
          listen-http = ":${toString cfg.port}";
          behind-proxy = true;
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/".proxyPass = "http://127.0.0.1:${toString cfg.port}";
      };
    };
  };
}
