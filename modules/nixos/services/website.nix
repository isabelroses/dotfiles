{
  lib,
  self,
  config,
  extpkgs,
  ...
}:
let
  inherit (self.lib) mkService;
  inherit (lib.modules) mkIf;

  inherit (config.networking) domain;
  cfg = config.garden.services.isabelroses-website;
in
{
  imports = [
    (mkService "isabelroses-website" { inherit domain; })
  ];

  config = mkIf cfg.enable {
    services.nginx.virtualHosts = {
      ${cfg.domain} = {
        serverAliases = [ "www.${cfg.domain}" ];
        enableACME = true;
        root = extpkgs.isabelroses-website;
        locations = {
          "/".tryFiles = "$uri $uri.html $uri/ =404";
          "/_astro/".extraConfig = ''
            expires max;
          '';
        };
        extraConfig = ''
          rewrite ^/(.+)/$ /$1 permanent;
          error_page 404 /404.html;
        '';
      };
    };
  };
}
