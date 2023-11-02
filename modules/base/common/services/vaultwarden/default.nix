{
  config,
  lib,
  ...
}: let
  inherit (config.networking) domain;
  vaultwarden_domain = "vault.${domain}";

  cfg = config.modules.services.vaultwarden;

  inherit (lib) mkIf sslTemplate;
in {
  config = mkIf cfg.enable {
    # this forces the system to create backup folder
    systemd.services = {
      vaultwarden.after = ["sops-nix.service"];
      backup-vaultwarden.serviceConfig = {
        User = "root";
        Group = "root";
      };
    };

    services = {
      vaultwarden = {
        enable = true;
        environmentFile = config.sops.secrets.vaultwarden-env.path;
        backupDir = "/srv/storage/vaultwarden/backup";
        config = {
          DOMAIN = "https://";
          SIGNUPS_ALLOWED = false;
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = 8222;
          extendedLogging = true;
          invitationsAllowed = true;
          useSyslog = true;
          logLevel = "warn";
          showPasswordHint = false;
          signupsAllowed = false;
          signupsDomainsWhitelist = "${domain}";
          signupsVerify = true;
          smtpAuthMechanism = "Login";
          smtpFrom = "vaultwarden@${domain}";
          smtpFromName = "Isabelroses's Vaultwarden Service";
          smtpHost = "mail.${domain}";
          smtpPort = 465;
          smtpSecurity = "force_tls";
          dataDir = "/srv/storage/vaultwarden";
        };
      };

      nginx.virtualHosts.${vaultwarden_domain} =
        {
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
            extraConfig = "proxy_pass_header Authorization;";
          };
        }
        // sslTemplate;
    };
  };
}
