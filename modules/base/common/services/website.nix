{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.modules.services;

  inherit (config.networking) domain;
  inherit (lib) mkIf template;
in {
  imports = [inputs.isabelroses-website.nixosModules.default];

  config = mkIf cfg.isabelroses-website.enable {
    services.isabelroses-website.enable = true;

    services.nginx.virtualHosts.${domain} =
      {
        locations."/".proxyPass = "http://127.0.0.1:3000";
      }
      // template.ssl domain;
  };
}
