{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  inherit (config.networking) domain;
  kanidm_domain = "sso.${domain}";
  certDir = config.security.acme.certs.${domain}.directory;

  cfg = config.modules.services;
in {
  config = mkIf cfg.kanidm.enable {
    # might need this later
    # https://discourse.nixos.org/t/reuse-lets-encrypt-acme-certificate-for-multiple-services-with-lego/6720
    # https://ashhhleyyy.dev/blog/2023-02-05-from-keycloak-to-kanidm

    services = {
      kanidm = {
        enableServer = true;
        serverSettings = {
          domain = kanidm_domain;
          origin = "https://${kanidm_domain}";
          bindaddress = "127.0.0.1:8443";
          ldapbindaddress = "127.0.0.1:3636";
          trust_x_forward_for = true;
          tls_chain = "${certDir}/fullchain.pem";
          tls_key = "${certDir}/key.pem";
          # online_backup = {
          #   path = "/srv/storage/kanidm/backups";
          #   schedule = "0 0 * * *";
          # };
        };
      };

      nginx.virtualHosts.${kanidm_domain} =
        {
          locations."/".proxyPass = "https://${config.services.kanidm.serverSettings.bindaddress}";
        }
        // lib.template.ssl domain;
    };

    systemd.services.kanidm = {
      after = ["acme-selfsigned-internal.${domain}.target"];
      serviceConfig = {
        SupplementaryGroups = [config.security.acme.certs.${domain}.group];
        BindReadOnlyPaths = [certDir];
      };
    };
  };
}
