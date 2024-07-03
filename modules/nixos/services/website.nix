{
  lib,
  config,
  inputs',
  ...
}:
let
  inherit (config.networking) domain;
  inherit (lib)
    mkIf
    template
    getExe
    mkServiceOption
    ;

  cfg = config.garden.services.isabelroses-website;
in
{
  options.garden.services.isabelroses-website = mkServiceOption "isabelroses-website" {
    port = 3000;
    domain = "isabelroses.com";
  };

  config = mkIf cfg.enable {
    systemd.services."isabelroses-website" = {
      description = "isabelroses.com";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ inputs'.beapkgs.packages.isabelroses-website ];

      serviceConfig = {
        Type = "simple";
        ReadWritePaths = [ "/srv/storage/isabelroses.com" ];
        DynamicUser = true;
        ExecStart = "${getExe inputs'.beapkgs.packages.isabelroses-website}";
        Restart = "always";
      };
    };

    services.nginx.virtualHosts.${domain} = {
      locations."/".proxyPass = "http://${cfg.host}:${toString cfg.port}";
    } // template.ssl domain;
  };
}
