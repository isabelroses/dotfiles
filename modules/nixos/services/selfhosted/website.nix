{
  lib,
  self,
  config,
  inputs',
  ...
}:
let
  inherit (self.lib) template;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (self.lib.services) mkServiceOption;

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

      environment = {
        DONOS_FILE = "${serve}/donos.json";
        PORT = toString cfg.port;
      };

      serviceConfig = {
        Type = "simple";
        ReadWritePaths = [ serve ];
        DynamicUser = true;
        ExecStart = getExe inputs'.tgirlpkgs.packages.isabelroses-website;
        Restart = "always";
      } // template.systemd;
    };

    services.nginx.virtualHosts.${domain} = {
      locations."/".proxyPass = "http://${cfg.host}:${toString cfg.port}";
    } // template.ssl domain;
  };
}
