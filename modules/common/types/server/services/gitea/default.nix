{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.services.gitea;
  inherit (config.networking) domain;
  gitea_domain = "git.${domain}";

  # stole this from https://git.winston.sh/winston/deployment-flake/src/branch/main/config/services/gitea.nix who stole it from https://github.com/getchoo
  theme = pkgs.fetchzip {
    url = "https://github.com/catppuccin/gitea/releases/download/v0.4.1/catppuccin-gitea.tar.gz";
    sha256 = "sha256-14XqO1ZhhPS7VDBSzqW55kh6n5cFZGZmvRCtMEh8JPI=";
    stripRoot = false;
  };
in {
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [config.services.gitea.settings.server.HTTP_PORT];

    systemd.services = {
      gitea = {
        after = ["sops-nix.service"];
        preStart = let
          inherit (config.services.gitea) stateDir;
        in
          lib.mkAfter ''
            rm -rf ${stateDir}/custom/public
            mkdir -p ${stateDir}/custom/public
            ln -sf ${theme} ${stateDir}/custom/public/css
          '';
      };
    };

    services = {
      gitea = {
        enable = true;
        package = pkgs.forgejo;
        appName = "iztea";
        lfs.enable = true;
        user = "git";
        group = "git";
        database.user = "git";
        stateDir = "/srv/storage/gitea/data";

        mailerPasswordFile = config.sops.secrets.mailserver-gitea-nohash.path;
        dump = {
          enable = true;
          backupDir = "/srv/storage/gitea/dump";
          interval = "06:00";
          type = "tar.zst";
        };

        settings = {
          server = {
            ROOT_URL = "https://${gitea_domain}";
            HTTP_PORT = 7000;
            DOMAIN = "${gitea_domain}";

            START_SSH_SERVER = false;
            BUILTIN_SSH_SERVER_USER = "git";
            SSH_PORT = 30;
            DISABLE_ROUTER_LOG = true;
            SSH_CREATE_AUTHORIZED_KEYS_FILE = true;
            LANDING_PAGE = "/explore/repos";
          };

          attachment.ALLOWED_TYPES = "*/*";
          service.DISABLE_REGISTRATION = true;
          ui = {
            DEFAULT_THEME = "catppuccin-mocha-sapphire";
            THEMES =
              builtins.concatStringsSep
              ","
              (["auto,forgejo-auto,forgejo-dark,forgejo-light,arc-gree,gitea"]
                ++ (map (name: lib.removePrefix "theme-" (lib.removeSuffix ".css" name))
                  (builtins.attrNames (builtins.readDir theme))));
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
            SUBJECT_PREFIX = "iztea Gitea: ";
            SMTP_ADDR = "mail.${domain}";
            USER = "gitea@${domain}";
          };
        };
      };

      openssh = {
        extraConfig = ''
          Match User git
            AuthorizedKeysCommandUser git
            AuthorizedKeysCommand ${lib.getExe pkgs.forgejo} keys -e git -u %u -t %t -k %k
          Match all
        '';
      };
    };
  };
}
