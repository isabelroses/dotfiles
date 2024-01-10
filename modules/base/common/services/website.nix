{
  config,
  lib,
  inputs',
  ...
}: let
  cfg = config.modules.services;
  inherit (config.networking) domain;
  inherit (lib) mkIf template;
in {
  config = mkIf cfg.isabelroses-web.enable {
    systemd.services."isabelroses-web" = {
      script = "./${inputs'.isabelroses-web.packages.default}/bin/isabelroses.com";
    };

    services.nginx.virtualHosts.${domain} =
      {
        locations."/".proxyPass = "http://127.0.0.1:3000";
      }
      // template.ssl domain;
  };
}
