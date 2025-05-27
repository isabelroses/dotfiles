# might need this later
# https://discourse.nixos.org/t/reuse-lets-encrypt-acme-certificate-for-multiple-services-with-lego/6720
# https://ashhhleyyy.dev/blog/2023-02-05-from-keycloak-to-kanidm
{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption mkSystemSecret;

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
      postgresql.enable = true;

      nginx.vhosts.${cfg.domain} = {
        locations."/".proxyPass = "https://${config.services.kanidm.serverSettings.bindaddress}";
      };
    };

    age.secrets = {
      kanidm-admin-password = mkSystemSecret {
        file = "kanidm/admin-password";
        owner = "kanidm";
        group = "kanidm";
        mode = "440";
      };
      kanidm-idm-admin-password = mkSystemSecret {
        file = "kanidm/idm-admin-password";
        owner = "kanidm";
        group = "kanidm";
        mode = "440";
      };
      kanidm-oauth2-grafana = mkSystemSecret {
        file = "kanidm/oauth2/grafana";
        owner = "kanidm";
        group = "kanidm";
        mode = "440";
      };
      kanidm-oauth2-forgejo = mkSystemSecret {
        file = "kanidm/oauth2/forgejo";
        owner = "kanidm";
        group = "kanidm";
        mode = "440";
      };
    };

    services.kanidm = {
      # we need to change the package so we have patches that allow us to provision secrets
      package = pkgs.kanidm.withSecretProvisioning;

      enableServer = true;
      serverSettings = {
        version = "2";
        inherit (cfg) domain;
        origin = "https://${cfg.domain}";
        bindaddress = "${cfg.host}:${toString cfg.port}";
        ldapbindaddress = "${cfg.host}:3636";
        tls_chain = "${certDir}/fullchain.pem";
        tls_key = "${certDir}/key.pem";

        online_backup = {
          path = "/srv/storage/kanidm/backups";
          schedule = "0 0 * * *";
        };
      };

      provision = {
        enable = true;

        adminPasswordFile = config.age.secrets.kanidm-admin-password.path;
        idmAdminPasswordFile = config.age.secrets.kanidm-idm-admin-password.path;

        persons = {
          isabel = {
            displayName = "isabel";
            legalName = "isabel";
            mailAddresses = [ "isabel@${rdomain}" ];
            groups = [
              "grafana.access"
              "grafana.admins"
              "forgejo.access"
              "forgejo.admins"
            ];
          };

          robin = {
            displayName = "robin";
            legalName = "robin";
            mailAddresses = [ "robin@${rdomain}" ];
            groups = [
              "grafana.access"
              "forgejo.access"
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
            originUrl = "https://${cfg'.grafana.domain}/login/generic_oauth";
            originLanding = "https://${cfg'.grafana.domain}/";
            basicSecretFile = config.age.secrets.kanidm-oauth2-grafana.path;
            preferShortUsername = true;
            scopeMaps."grafana.access" = [
              "openid"
              "email"
              "profile"
            ];
            claimMaps.groups = {
              joinType = "array";
              valuesByGroup."grafana.admins" = [
                "editor"
                "admin"
                "server_admin"
              ];
            };
          };

          forgejo = {
            displayName = "Forgejo";
            originUrl = "https://${cfg'.forgejo.domain}/user/oauth2/Isabel%27s%20SSO/callback";
            originLanding = "https://${cfg'.forgejo.domain}/";
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

    systemd.services.kanidm = {
      after = [ "acme-selfsigned-internal.${rdomain}.target" ];
      serviceConfig = {
        RestartSec = "60";
        SupplementaryGroups = [ certs.group ];
        BindReadOnlyPaths = [
          certDir
          "/run/agenix/" # provide access to secrets
        ];
      };
    };
  };
}
