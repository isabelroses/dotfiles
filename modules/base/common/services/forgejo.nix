{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.services.forgejo;
  inherit (config.networking) domain;
  forgejo_domain = "git.${domain}";

  inherit (lib) mkIf template;

  # stole this from https://git.winston.sh/winston/deployment-flake/src/branch/main/config/services/gitea.nix who stole it from https://github.com/getchoo
  theme = pkgs.fetchzip {
    url = "https://github.com/catppuccin/gitea/releases/download/v0.4.1/catppuccin-gitea.tar.gz";
    sha256 = "sha256-14XqO1ZhhPS7VDBSzqW55kh6n5cFZGZmvRCtMEh8JPI=";
    stripRoot = false;
  };
in {
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      config.services.forgejo.settings.server.HTTP_PORT
      config.services.forgejo.settings.server.SSH_PORT
    ];

    modules.services.database = {
      redis.enable = true;
      postgresql.enable = true;
    };

    systemd.services = {
      forgejo = {
        after = ["sops-nix.service"];
        preStart = let
          inherit (config.services.forgejo) stateDir;
        in
          lib.mkAfter ''
            rm -rf ${stateDir}/custom/public/assets
            mkdir -p ${stateDir}/custom/public/assets
            ln -sf ${theme} ${stateDir}/custom/public/assets/css
          '';
      };
    };

    services = {
      forgejo = {
        enable = true;
        package = pkgs.forgejo;
        stateDir = "/srv/storage/forgejo/data";
        lfs.enable = true;

        mailerPasswordFile = config.sops.secrets.mailserver-git-nohash.path;

        settings = {
          server = {
            PROTOCOL = "http+unix";
            ROOT_URL = "https://${forgejo_domain}";
            HTTP_PORT = 7000;
            DOMAIN = "${forgejo_domain}";

            BUILTIN_SSH_SERVER_USER = "git";
            DISABLE_ROUTER_LOG = true;
            # LANDING_PAGE = "/explore/repos";

            START_SSH_SERVER = true;
            SSH_CREATE_AUTHORIZED_KEYS_FILE = true;
            SSH_PORT = 2222;
            SSH_LISTEN_PORT = 2222;
          };

          api.ENABLE_SWAGGER = false;

          default.APP_NAME = "iztea";
          attachment.ALLOWED_TYPES = "*/*";

          ui = {
            DEFAULT_THEME = "catppuccin-mocha-sapphire";
            THEMES =
              builtins.concatStringsSep
              ","
              (["auto,forgejo-auto,forgejo-dark,forgejo-light,arc-gree,gitea"]
                ++ (map (name: lib.removePrefix "theme-" (lib.removeSuffix ".css" name))
                  (builtins.attrNames (builtins.readDir theme))));
          };

          "ui.meta" = {
            AUTHOR = "Isabel Roses";
            DESCRIPTION = "A super cool place to host git repos";
            KEYWORDS = "git,self-hosted,gitea,forgejo,isabelroses,catppuccin,open-source,nix,nixos";
          };

          actions = {
            ENABLED = true;
            DEFAULT_ACTIONS_URL = "https://code.forgejo.org";
          };

          database = {
            DB_TYPE = lib.mkForce "postgres";
            HOST = "/run/postgresql";
            NAME = "forgejo";
            USER = "forgejo";
            PASSWD = "forgejo";
          };

          cache = {
            ENABLED = true;
            ADAPTER = "redis";
            HOST = "redis://:forgejo@localhost:6371";
          };

          service = {
            DISABLE_REGISTRATION = true;
            EMAIL_DOMAIN_ALLOWLIST = "isabelroses.com";
          };

          session = {
            COOKIE_SECURE = true;
            # Sessions last for 1 week
            SESSION_LIFE_TIME = 86400 * 7;
          };

          other = {
            SHOW_FOOTER_VERSION = false;
            SHOW_FOOTER_TEMPLATE_LOAD_TIME = false;
            ENABLE_FEED = false;
          };

          migrations.ALLOWED_DOMAINS = "github.com, *.github.com, gitlab.com, *.gitlab.com";
          packages.ENABLED = false;
          repository.PREFERRED_LICENSES = "MIT,GPL-3.0,GPL-2.0,LGPL-3.0,LGPL-2.1";

          "repository.upload" = {
            FILE_MAX_SIZE = 100;
            MAX_FILES = 10;
          };

          mailer = {
            ENABLED = true;
            PROTOCOL = "smtps";
            SMTP_ADDR = "mail.${domain}";
            USER = "git@${domain}";
          };
        };

        # backup
        dump = {
          enable = true;
          backupDir = "/srv/storage/forgejo/dump";
          interval = "06:00";
          type = "tar.zst";
        };
      };

      nginx.virtualHosts.${forgejo_domain} =
        {
          locations."/" = {
            recommendedProxySettings = true;
            proxyPass = "http://unix:/run/forgejo/forgejo.sock";
          };
        }
        // template.ssl domain;
    };
  };
}
