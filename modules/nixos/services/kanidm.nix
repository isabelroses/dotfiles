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
  inherit (self.lib) mkServiceOption mkSecret;

  rdomain = config.networking.domain;
  certs = config.security.acme.certs.${rdomain};
  certDir = certs.directory;

  cfg = config.garden.services.kanidm;
  cfg' = config.garden.services;
in
{
  options.garden.services.kanidm = mkServiceOption "kanidm" {
    port = 3010;
    domain = "sso.${rdomain}";
  };

  config = mkIf cfg.enable {
    garden.services = {
      postgresql.enable = true;
    };

    sops.secrets = {
      kanidm-admin-password = mkSecret {
        file = "kanidm";
        key = "admin-password";
        owner = "kanidm";
        group = "kanidm";
        mode = "440";
      };
      kanidm-idm-admin-password = mkSecret {
        file = "kanidm";
        key = "idm-admin-password";
        owner = "kanidm";
        group = "kanidm";
        mode = "440";
      };
      kanidm-oauth2-forgejo = mkSecret {
        file = "kanidm";
        key = "oauth2-forgejo";
        owner = "kanidm";
        group = "kanidm";
        mode = "440";
      };
      kanidm-oauth2-linkwarden = mkSecret {
        file = "kanidm";
        key = "oauth2-linkwarden";
        owner = "kanidm";
        group = "kanidm";
        mode = "440";
      };
      kanidm-oauth2-wakapi = mkSecret {
        file = "kanidm";
        key = "oauth2-linkwarden";
        owner = "kanidm";
        group = "kanidm";
        mode = "440";
      };
      kanidm-oauth2-immich = mkSecret {
        file = "kanidm";
        key = "oauth2-immich";
        owner = "kanidm";
        group = "kanidm";
        mode = "440";
      };
      kanidm-oauth2-hostling = mkSecret {
        file = "kanidm";
        key = "oauth2-hostling";
        owner = "kanidm";
        group = "kanidm";
        mode = "440";
      };
    };

    services = {
      kanidm = {
        # we need to change the package so we have patches that allow us to provision secrets
        package = pkgs.kanidmWithSecretProvisioning_1_8;

        server = {
          enable = true;

          settings = {
            version = "2";
            inherit (cfg) domain;
            origin = "https://${cfg.domain}";
            bindaddress = "${cfg.host}:${toString cfg.port}";
            ldapbindaddress = "${cfg.host}:3636";
            tls_chain = "${certDir}/fullchain.pem";
            tls_key = "${certDir}/key.pem";

            # TODO: reenable this + do systemd tempfiles + cleanup
            # online_backup = {
            #   path = "/srv/storage/kanidm/backups";
            #   schedule = "0 0 * * *";
            # };
          };
        };

        provision = {
          enable = true;

          adminPasswordFile = config.sops.secrets.kanidm-admin-password.path;
          idmAdminPasswordFile = config.sops.secrets.kanidm-idm-admin-password.path;

          persons.isabel = {
            displayName = "isabel";
            legalName = "isabel";
            mailAddresses = [ "isabel@${rdomain}" ];
            groups = [
              "forgejo.access"
              "forgejo.admins"
              "linkwarden.access"
              "wakapi.access"
              "immich.access"
              "hostling.access"
            ];
          };

          groups = {
            "forgejo.access" = { };
            "forgejo.admins" = { };

            "linkwarden.access" = { };

            "wakapi.access" = { };

            "immich.access" = { };

            "hostling.access" = { };
          };

          systems.oauth2 = {
            forgejo = {
              displayName = "Forgejo";
              originUrl = "https://${cfg'.forgejo.domain}/user/oauth2/Isabel%27s%20SSO/callback";
              originLanding = "https://${cfg'.forgejo.domain}/";
              basicSecretFile = config.sops.secrets.kanidm-oauth2-forgejo.path;
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

            linkwarden = {
              displayName = "linkwarden";
              originUrl = "https://bookmark.isabelroses.com/api/v1/auth/callback/authentik";
              originLanding = "https://bookmark.isabelroses.com/";
              basicSecretFile = config.sops.secrets.kanidm-oauth2-linkwarden.path;
              preferShortUsername = true;
              enableLegacyCrypto = true;
              scopeMaps."linkwarden.access" = [
                "openid"
                "email"
                "profile"
              ];
            };

            wakapi = {
              displayName = "wakapi";
              originUrl = "https://${cfg'.wakapi.domain}/oidc/wakapi/callback";
              originLanding = "https://${cfg'.wakapi.domain}/";
              basicSecretFile = config.sops.secrets.kanidm-oauth2-wakapi.path;
              allowInsecureClientDisablePkce = true;
              preferShortUsername = true;
              scopeMaps."wakapi.access" = [
                "openid"
                "email"
                "profile"
              ];
            };

            immich = {
              displayName = "immich";
              originUrl = [
                "https://${cfg'.immich.domain}/auth/login"
                "https://${cfg'.immich.domain}/api/oauth/mobile-redirect"
              ];
              originLanding = "https://${cfg'.immich.domain}/";
              basicSecretFile = config.sops.secrets.kanidm-oauth2-immich.path;
              preferShortUsername = true;
              scopeMaps."immich.access" = [
                "openid"
                "email"
                "profile"
              ];
            };

            hostling = {
              displayName = "hostling";
              originUrl = "https://${cfg'.hostling.domain}/api/auth/login/openid-connect/callback";
              originLanding = "https://${cfg'.hostling.domain}/";
              basicSecretFile = config.sops.secrets.kanidm-oauth2-hostling.path;
              allowInsecureClientDisablePkce = true;
              preferShortUsername = true;
              scopeMaps."hostling.access" = [
                "openid"
                "email"
                "profile"
              ];
            };

          };
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/".proxyPass = "https://${config.services.kanidm.server.settings.bindaddress}";
      };
    };

    systemd.services.kanidm = {
      after = [ "acme-selfsigned-internal.${rdomain}.target" ];
      serviceConfig = {
        RestartSec = "60";
        SupplementaryGroups = [ certs.group ];
        BindReadOnlyPaths = [ certDir ];
      };
    };
  };
}
