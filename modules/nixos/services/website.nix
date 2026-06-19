{
  lib,
  self,
  config,
  extpkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
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
        serverAliases = [ "www.${cfg.domain}" ];
        enableACME = true;
        root = extpkgs.isabelroses-website;
      };
    };
  };
}
