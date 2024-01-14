{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf template;

  rdomain = config.networking.domain;
  cfg = config.modules.services.vaultwarden;
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
          DOMAIN = "https://${cfg.domain}";
          SIGNUPS_ALLOWED = false;
          ROCKET_ADDRESS = cfg.host;
          ROCKET_PORT = cfg.port;
          extendedLogging = true;
          invitationsAllowed = true;
          useSyslog = true;
          logLevel = "warn";
          showPasswordHint = false;
          signupsAllowed = false;
          signupsDomainsWhitelist = "${rdomain}";
          signupsVerify = true;
          smtpAuthMechanism = "Login";
          smtpFrom = "vaultwarden@${rdomain}";
          smtpFromName = "Isabelroses's Vaultwarden Service";
          smtpHost = config.modules.services.mailserver.domain;
          smtpPort = 465;
          smtpSecurity = "force_tls";
          dataDir = "/srv/storage/vaultwarden";
        };
      };

      nginx.virtualHosts.${cfg.domain} =
        {
          locations."/" = {
            proxyPass = "http://${cfg.host}:${toString cfg.port}";
            extraConfig = "proxy_pass_header Authorization;";
          };
        }
        // template.ssl rdomain;
    };
  };
}
