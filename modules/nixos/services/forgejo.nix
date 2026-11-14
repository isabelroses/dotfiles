{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  cfg = config.garden.services.forgejo;
  socket = "http://unix:${config.services.forgejo.settings.server.HTTP_ADDR}";
  rdomain = config.networking.domain;

  inherit (lib.modules) mkIf mkForce;
  inherit (self.lib) mkServiceOption mkSecret journalJail;
in
{
  options.garden.services.forgejo = mkServiceOption "forgejo" {
    port = 3011;
    domain = "git.${rdomain}";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      mailserver-git-nohash = mkSecret {
        file = "mailserver";
        key = "git-nohash";
        owner = "forgejo";
        group = "forgejo";
      };
    };

    garden.services = {
      redis.enable = true;
      postgresql.enable = true;

      borgbackup.jobs.forgejo = {
        paths = [ config.services.forgejo.stateDir ];
      };
    };

    networking.firewall.allowedTCPPorts = [
      config.services.forgejo.settings.server.SSH_PORT
    ];

    catppuccin.forgejo = {
      enable = true;
      flavor = "mocha";
      accent = "pink";
    };

    services = {
      # api and git auth failures only show as 401s, and git sends one before
      # every authenticated request, so it gets more tries. the router log
      # these match is turned on below
      fail2ban.jails.forgejo = journalJail "forgejo" [
        ''^.*Failed authentication attempt for .* from <ADDR>(?::\d+)?:''
        ''^.*router: completed \S+ \S+ for <ADDR>:\d+, 401 Unauthorized''
      ] { maxretry = 10; };

      forgejo = {
        enable = true;
        package = pkgs.forgejo;
        stateDir = "/srv/storage/forgejo/data";
        lfs.enable = true;

        secrets.mailer.PASSWD = config.sops.secrets.mailserver-git-nohash.path;

        settings = {
          federation.ENABLED = true;

          server = {
            PROTOCOL = "http+unix";
            ROOT_URL = "https://${cfg.domain}";
            HTTP_PORT = cfg.port;
            DOMAIN = cfg.domain;

            START_SSH_SERVER = false;
            # BUILTIN_SSH_SERVER_USER = "git";
            # LANDING_PAGE = "/explore/repos";

            SSH_CREATE_AUTHORIZED_KEYS_FILE = true;
            SSH_PORT = lib.lists.head config.services.openssh.ports;

            # fix gravatar images
            OFFLINE_MODE = false;
          };

          api.ENABLE_SWAGGER = false;

          # the fail2ban jail above bans on the 401s in these
          log."logger.router.MODE" = ",";

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
            HOST =
              let
                inherit (config.garden.services) redis;
              in
              "redis://:forgejo@${redis.host}:${toString redis.port}";
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

          repository = {
            PREFERRED_LICENSES = "MIT,GPL-3.0,GPL-2.0,LGPL-3.0,LGPL-2.1";
            # scrapers love hammering archive downloads (.bundle especially);
            # there is no per-format toggle, so zip/tar.gz go too
            DISABLE_DOWNLOAD_SOURCE_ARCHIVES = true;
          };

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
        dump.enable = false;
      };

      openssh.settings.UsePAM = mkForce true;

      postgresql = {
        ensureDatabases = [ "forgejo" ];
        ensureUsers = lib.lists.singleton {
          name = "forgejo";
          ensureDBOwnership = true;
        };
      };

      nginx = {
        appendHttpConfig = ''
          limit_req_zone $binary_remote_addr zone=forgejo_heavy:10m rate=30r/m;
        '';

        virtualHosts.${cfg.domain}.locations = {
          "/".proxyPass = socket;

          # crawlers walk these endlessly and each one is expensive to render
          "~ ^/[^/]+/[^/]+/(blame|commits|compare|raw)/" = {
            proxyPass = socket;
            extraConfig = ''
              limit_req zone=forgejo_heavy burst=20 nodelay;
              limit_req_status 429;
            '';
          };
        };
      };
    };
  };
}
