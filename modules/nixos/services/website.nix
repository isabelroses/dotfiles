{
  lib,
  config,
  inputs',
  ...
}:
let
  inherit (config.networking) domain;
  inherit (lib) mkIf template getExe;

  cfg = config.modules.services.isabelroses-website;
in
{
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
