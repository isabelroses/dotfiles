{ config, lib, ... }:
let
  inherit (lib) mkIf template mkServiceOption;

  rdomain = config.networking.domain;
  cfg = config.modules.services.dev.atuin;
in
{
  options.modules.services.dev.atuin = mkServiceOption "atuin" {
    port = 43473;
    domain = "atuin.${rdomain}";
  };

  config.services = mkIf cfg.enable {
    atuin = {
      enable = true;
      inherit (cfg) port host;
      openRegistration = false;
      maxHistoryLength = 1024 * 16;
    };

    nginx.virtualHosts.${cfg.domain} = {
      locations."/" = {
        proxyPass = "http://${cfg.host}:${toString cfg.port}";
      };
    } // template.ssl rdomain;
  };
}
