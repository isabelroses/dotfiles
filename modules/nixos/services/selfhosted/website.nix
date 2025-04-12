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
  inherit (self.lib.secrets) mkSecret;

  inherit (config.networking) domain;

  cfg = config.garden.services.isabelroses-website;

  serve = "/srv/storage/isabelroses.com";

  link = "http://${cfg.host}:${toString cfg.port}";
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

    age.secrets.anubis-isabelroses-website = mkSecret {
      file = "anubis/isabelroses-website";
      owner = "anubis";
      group = "anubis";
    };

    services = {
      anubis = mkIf config.garden.services.anubis.enable {
        instances.isabelroses-website.settings = {
          TARGET = link;
          OG_PASSTHROUGH = true;
          ED25519_PRIVATE_KEY_HEX_FILE = config.age.secrets.anubis-isabelroses-website.path;
        };
      };

      nginx.virtualHosts.${domain} = {
        locations."/".proxyPass =
          if config.garden.services.anubis.enable then
            "http://unix:${config.services.anubis.instances.isabelroses-website.settings.BIND}"
          else
            link;
      } // template.ssl domain;
    };
  };
}
