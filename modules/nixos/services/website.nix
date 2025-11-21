{
  lib,
  self,
  config,
  inputs',
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption;

  inherit (config.networking) domain;
  cfg = config.garden.services.isabelroses-website;
in
{
  options.garden.services.isabelroses-website = mkServiceOption "isabelroses-website" {
    inherit domain;
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts = {
      ${cfg.domain} = {
        serverName = "${cfg.domain} www.${cfg.domain}";
        enableACME = false;
        useACMEHost = cfg.domain;
        root = inputs'.tgirlpkgs.packages.isabelroses-website;
      };
    };

    security.acme.certs.${cfg.domain} = {
      extraDomainNames = [ "www.${cfg.domain}" ];
    };
  };
}
