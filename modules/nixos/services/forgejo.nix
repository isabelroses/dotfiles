{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  cfg = config.garden.services.forgejo;
  rdomain = config.networking.domain;

  inherit (lib) mkIf mkForce;
  inherit (self.lib) mkServiceOption mkSystemSecret;
in
{
  options.garden.services.forgejo = mkServiceOption "forgejo" {
    port = 7000;
    domain = "git.${rdomain}";
  };

  config = mkIf cfg.enable {
    age.secrets = {
      mailserver-git-nohash = mkSystemSecret {
        file = "mailserver/git-nohash";
        owner = "forgejo";
        group = "forgejo";
      };

      anubis-forgejo = mkSystemSecret {
        file = "anubis/forgejo";
        owner = "anubis";
        group = "anubis";
      };
    };

    garden.services = {
      redis.enable = true;
      postgresql.enable = true;
    };

    networking.firewall.allowedTCPPorts = [
      config.services.forgejo.settings.server.HTTP_PORT
      config.services.forgejo.settings.server.SSH_PORT
    ];

    users = {
      groups.git = { };

      users.git = {
        isSystemUser = true;
        createHome = false;
        group = "git";
      };
    };

    catppuccin.forgejo = {
      enable = true;
      flavor = "mocha";
      accent = "pink";
    };

    services = {
      forgejo = {
        enable = true;
        package = pkgs.forgejo;
        stateDir = "/srv/storage/forgejo/data";
        lfs.enable = true;

        secrets.mailer.PASSWD = config.age.secrets.mailserver-git-nohash.path;

        settings = {
          federation.ENABLED = true;

          server = {
            PROTOCOL = "http+unix";
            ROOT_URL = "https://${cfg.domain}";
            HTTP_PORT = cfg.port;
            DOMAIN = cfg.domain;

            BUILTIN_SSH_SERVER_USER = "git";
            DISABLE_ROUTER_LOG = true;
            # LANDING_PAGE = "/explore/repos";

            START_SSH_SERVER = true;
            SSH_CREATE_AUTHORIZED_KEYS_FILE = true;
            SSH_PORT = 2222;
            SSH_LISTEN_PORT = 2222;

            # fix gravatar images
            OFFLINE_MODE = false;
          };

          api.ENABLE_SWAGGER = false;

          DEFAULT.APP_NAME = "iztea";
          attachment.ALLOWED_TYPES = "*/*";

          "ui.meta" = {
            AUTHOR = "Isabel Roses";
            DESCRIPTION = "A super cool place to host git repos";
            KEYWORDS = "git,self-hosted,gitea,forgejo,isabelroses,catppuccin,open-source,nix,nixos";
          };

          actions = {
            ENABLED = false;
            DEFAULT_ACTIONS_URL = "https://code.forgejo.org";
          };

          database = {
            DB_TYPE = mkForce "postgres";
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

          oauth2_client = {
            ACCOUNT_LINKING = "login";
            USERNAME = "nickname";
            ENABLE_AUTO_REGISTRATION = false;
            REGISTER_EMAIL_CONFIRM = false;
            UPDATE_AVATAR = true;
          };

          service = {
            DISABLE_REGISTRATION = true;
            ALLOW_ONLY_INTERNAL_REGISTRATION = true;
            EMAIL_DOMAIN_ALLOWLIST = "isabelroses.com";
            ALLOW_ONLY_EXTERNAL_REGISTRATION = false;
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
            SMTP_ADDR = config.garden.services.mailserver.domain;
            USER = "git@${rdomain}";
          };
        };

        # backup
        dump = {
          enable = false;
          backupDir = "/srv/storage/forgejo/dump";
          interval = "06:00";
          type = "tar.zst";
        };
      };

      postgresql = {
        ensureDatabases = [ "forgejo" ];
        ensureUsers = lib.singleton {
          name = "forgejo";
          ensureDBOwnership = true;
        };
      };

      anubis = mkIf config.garden.services.anubis.enable {
        instances.forgejo.settings = {
          TARGET = "unix://${config.services.forgejo.settings.server.HTTP_ADDR}";
          ED25519_PRIVATE_KEY_HEX_FILE = config.age.secrets.anubis-forgejo.path;
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass =
            "http://unix:"
            + (
              if config.garden.services.anubis.enable then
                config.services.anubis.instances.forgejo.settings.BIND
              else
                config.services.forgejo.settings.server.HTTP_ADDR
            );
        };
      };
    };
  };
}
