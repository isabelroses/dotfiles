{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.usrEnv.services.gitea;
  inherit (config.networking) domain;
  gitea_domain = "git.${domain}";
in {
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [config.services.gitea.settings.server.HTTP_PORT];

    services = {
      gitea = {
        enable = true;
        package = pkgs.forgejo;
        appName = "iztea";
        lfs.enable = true;
        user = "git";
        database.user = "git";
        stateDir = "/srv/storage/gitea/data";

        mailerPasswordFile = config.sops.secrets.mailserver-gitea.path;
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
            SSH_PORT = 22;
            DISABLE_ROUTER_LOG = true;
            SSH_CREATE_AUTHORIZED_KEYS_FILE = true;
            LANDING_PAGE = "/explore/repos";
          };

          attachment.ALLOWED_TYPES = "*/*";
          service.DISABLE_REGISTRATION = true;
          ui.DEFAULT_THEME = "arc-green";
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
