{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (config.networking) domain;
  inherit (lib) mkIf template;

  cfg = config.modules.services.isabelroses-website;
in {
  imports = [inputs.isabelroses-website.nixosModules.default];

  config = mkIf cfg.enable {
    services.isabelroses-website.enable = true;

    services.nginx.virtualHosts.${domain} =
      {
        locations."/".proxyPass = "http://${cfg.host}:${toString cfg.port}";
      }
      // template.ssl domain;
  };
}
