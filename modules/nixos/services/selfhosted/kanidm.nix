# might need this later
# https://discourse.nixos.org/t/reuse-lets-encrypt-acme-certificate-for-multiple-services-with-lego/6720
# https://ashhhleyyy.dev/blog/2023-02-05-from-keycloak-to-kanidm
{ lib, config, ... }:
let
  inherit (lib) template;
  inherit (lib.modules) mkIf;
  inherit (lib.services) mkServiceOption;
  inherit (lib.secrets) mkSecret;

  rdomain = config.networking.domain;
  certs = config.security.acme.certs.${rdomain};
  certDir = certs.directory;

  cfg = config.garden.services.kanidm;
  cfg' = config.garden.services;
in
{
  options.garden.services.kanidm = mkServiceOption "kanidm" {
    port = 8443;
    domain = "sso.${rdomain}";
  };

  config = mkIf cfg.enable {
    garden.services = {
      nginx.enable = true;
      postgresql.enable = true;
    };

    age.secrets = {
      kanidm-admin-password = mkSecret { file = "kanidm/admin-password"; };
      kanidm-idm-admin-password = mkSecret { file = "kanidm/idm-admin-password"; };
      kanidm-oauth2-grafana = mkSecret { file = "kanidm/oauth2/grafana"; };
      kanidm-oauth2-forgejo = mkSecret { file = "kanidm/oauth2/forgejo"; };
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

          online_backup = {
            path = "/srv/storage/kanidm/backups";
            schedule = "0 0 * * *";
          };

          provision =
            let
              inherit (config.garden.system) mainUser;
            in
            {
              enable = true;

              adminPasswordFile = config.age.secrets.kanidm-admin-password.path;
              idmAdminPasswordFile = config.age.secrets.kanidm-idm-admin-password.path;

              persons = {
                ${mainUser} = {
                  displayName = mainUser;
                  legalName = mainUser;
                  mailAddresses = [ "${mainUser}@${rdomain}" ];
                  groups = [
                    "grafana.access"
                    "grafana.admins"
                    "forgejo.access"
                    "forgejo.admins"
                  ];
                };
              };

              groups = {
                "grafana.access" = { };
                "grafana.admins" = { };

                "forgejo.access" = { };
                "forgejo.admins" = { };
              };

              systems.oauth2 = {
                grafana = {
                  displayName = "Grafana";
                  originUrl = "https://${cfg'.grafana.domain}/";
                  basicSecretFile = config.age.secrets.kanidm-oauth2-grafana.path;
                  preferShortUsername = true;
                  scopeMaps."grafana.access" = [
                    "openid"
                    "email"
                    "profile"
                  ];
                  claimMaps.groups = {
                    joinType = "array";
                    valuesByGroup = {
                      "grafana.editors" = [ "editor" ];
                      "grafana.admins" = [ "admin" ];
                      "grafana.server-admins" = [ "server_admin" ];
                    };
                  };
                };

                forgejo = {
                  displayName = "Forgejo";
                  originUrl = "https://${cfg'.forgejo.domain}/";
                  basicSecretFile = config.age.secrets.kanidm-oauth2-forgejo.path;
                  scopeMaps."forgejo.access" = [
                    "openid"
                    "email"
                    "profile"
                  ];
                  # WARNING: PKCE is currently not supported by gitea/forgejo,
                  # see https://github.com/go-gitea/gitea/issues/21376
                  allowInsecureClientDisablePkce = true;
                  preferShortUsername = true;
                  claimMaps.groups = {
                    joinType = "array";
                    valuesByGroup."forgejo.admins" = [ "admin" ];
                  };
                };
              };
            };
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
