{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib) mkServiceOption mkSecret journalJail;

  # https://github.com/dani-garcia/vaultwarden/wiki/Fail2Ban-Setup
  jail =
    failregex:
    journalJail "vaultwarden" [ failregex ] {
      maxretry = 3;
      bantime = 14400;
      findtime = 14400;
    };

  rdomain = config.networking.domain;
  cfg = config.garden.services.vaultwarden;
in
{
  options.garden.services.vaultwarden = mkServiceOption "vaultwarden" {
    port = 3013;
    domain = "vault.${rdomain}";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      vaultwarden-env = mkSecret {
        file = "vaultwarden";
        key = "env";
        owner = "vaultwarden";
        group = "vaultwarden";
      };
    };

    garden.services.borgbackup.jobs.vaultwarden = {
      paths = [ config.services.vaultwarden.config.DATA_DIR ];
    };

    services = {
      fail2ban.jails = {
        vaultwarden = jail ''^.*?Username or password is incorrect\. Try again\. IP: <ADDR>\. Username:.*$'';
        vaultwarden-admin = jail ''^.*?Invalid admin token\. IP: <ADDR>.*$'';
      };

      vaultwarden = {
        enable = true;
        environmentFile = config.sops.secrets.vaultwarden-env.path;

        # https://github.com/dani-garcia/vaultwarden/blob/1.34.1/.env.template
        config = {
          DOMAIN = "https://${cfg.domain}";
          ROCKET_ADDRESS = cfg.host;
          ROCKET_PORT = cfg.port;

          SIGNUPS_ALLOWED = false;
          # SIGNUPS_DOMAINS_WHITELIST = "${rdomain}";
          SIGNUPS_VERIFY = true;
          INVITATIONS_ALLOWED = true;

          SMTP_AUTH_MECHANISM = "Login";
          SMTP_FROM = "vaultwarden@${rdomain}";
          SMTP_FROM_NAME = "Isabelroses's Vaultwarden Service";
          SMTP_HOST = config.garden.services.mailserver.domain;
          SMTP_PORT = 465;
          SMTP_SECURITY = "force_tls";

          DATA_DIR = "/srv/storage/vaultwarden";
          SHOW_PASSWORD_HINT = false;

          LOG_LEVEL = "warn";
          EXTENDED_LOGGING = true;
          USE_SYS_LOG = true;
        };
      };

      # https://github.com/dani-garcia/vaultwarden/wiki/Proxy-examples
      nginx.virtualHosts.${cfg.domain} = {
        locations."/" = {
          proxyPass = "http://${cfg.host}:${toString cfg.port}";
          extraConfig = "proxy_pass_header Authorization;";
          proxyWebsockets = true;
        };
      };

      postgresql = {
        ensureDatabases = [ "vaultwarden" ];
        ensureUsers = lib.lists.singleton {
          name = "vaultwarden";
          ensureDBOwnership = true;
        };
      };
    };
  };
}
