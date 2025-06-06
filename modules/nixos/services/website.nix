{
  lib,
  self,
  config,
  inputs',
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.services) mkServiceOption;

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
        root = inputs'.tgirlpkgs.packages.isabelroses-website;
      };
    };
  };
}
