{
  lib,
  config,
  inputs',
  ...
}:
let
  inherit (lib) template;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.services) mkServiceOption;

  inherit (config.networking) domain;

  cfg = config.garden.services.isabelroses-website;

  serve = "/srv/storage/isabelroses.com";
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

      environment = {
        SERVE_DIR = serve;
      };

      serviceConfig = {
        Type = "simple";
        ReadWritePaths = [ serve ];
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
