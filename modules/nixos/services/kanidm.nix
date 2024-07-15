# might need this later
# https://discourse.nixos.org/t/reuse-lets-encrypt-acme-certificate-for-multiple-services-with-lego/6720
# https://ashhhleyyy.dev/blog/2023-02-05-from-keycloak-to-kanidm
{ lib, config, ... }:
let
  inherit (lib) template;
  inherit (lib.modules) mkIf;
  inherit (lib.services) mkServiceOption;

  rdomain = config.networking.domain;
  certs = config.security.acme.certs.${rdomain};
  certDir = certs.directory;

  cfg = config.garden.services.kanidm;
in
{
  options.garden.services.kanidm = mkServiceOption "kanidm" {
    port = 8443;
    domain = "sso.${rdomain}";
  };

  config = mkIf cfg.enable {
    garden.services = {
      networking.nginx.enable = true;
      database.postgresql.enable = true;
    };

    services = {
      kanidm = {
        enableServer = true;
        serverSettings = {
          inherit (cfg) domain;
          origin = "https://${cfg.domain}";
          bindaddress = "${cfg.host}:${toString cfg.port}";
          ldapbindaddress = "${cfg.host}:3636";
          trust_x_forward_for = true;
          tls_chain = "${certDir}/fullchain.pem";
          tls_key = "${certDir}/key.pem";
          # online_backup = {
          #   path = "/srv/storage/kanidm/backups";
          #   schedule = "0 0 * * *";
          # };
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/".proxyPass = "https://${config.services.kanidm.serverSettings.bindaddress}";
      } // template.ssl rdomain;
    };

    systemd.services.kanidm = {
      after = [ "acme-selfsigned-internal.${rdomain}.target" ];
      serviceConfig = {
        SupplementaryGroups = [ certs.group ];
        BindReadOnlyPaths = [ certDir ];
      };
    };
  };
}
