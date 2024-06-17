{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    template
    mkSecret
    mkServiceOption
    ;

  rdomain = config.networking.domain;
  cfg = config.modules.services.vaultwarden;
in
{
  options.modules.services.vaultwarden = mkServiceOption "vaultwarden" {
    port = 8222;
    domain = "vault.${rdomain}";
  };

  config = mkIf cfg.enable {
    age.secrets.vaultwarden-env = mkSecret {
      file = "vaultwarden-env";
      owner = "vaultwarden";
      group = "vaultwarden";
    };

    # this forces the system to create backup folder
    systemd.services.backup-vaultwarden.serviceConfig = {
      User = "root";
      Group = "root";
    };

    services = {
      vaultwarden = {
        enable = true;
        environmentFile = config.age.secrets.vaultwarden-env.path;
        backupDir = "/srv/storage/vaultwarden/backup";
        config = {
          DOMAIN = "https://${cfg.domain}";
          ROCKET_ADDRESS = cfg.host;
          ROCKET_PORT = cfg.port;
          extendedLogging = true;
          invitationsAllowed = true;
          useSyslog = true;
          logLevel = "warn";
          showPasswordHint = false;
          SIGNUPS_ALLOWED = false;
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

      nginx.virtualHosts.${cfg.domain} = {
        locations."/" = {
          proxyPass = "http://${cfg.host}:${toString cfg.port}";
          extraConfig = "proxy_pass_header Authorization;";
        };
      } // template.ssl rdomain;
    };
  };
}
