{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf template;

  rdomain = config.networking.domain;
  cfg = config.modules.services.dev.atuin;
in {
  services = mkIf (cfg.enable) {
    atuin = {
      enable = true;
      openRegistration = false;
      maxHistoryLength = 1024 * 16;
      port = cfg.port;
      host = cfg.host;
    };

    nginx.virtualHosts.${cfg.domain} =
      {
        locations."/" = {
          proxyPass = "http://${cfg.host}:${toString cfg.gport}";
        };
      }
      // template.ssl rdomain;
  };
}
