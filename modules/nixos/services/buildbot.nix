{
  lib,
  self,
  pkgs,
  config,
  inputs,
  ...
}:
let
  inherit (lib.modules) mkIf mkMerge;
  inherit (self.lib.services) mkServiceOption;
  inherit (self.lib.secrets) mkSecret;

  inherit (config.age) secrets;

  rdomain = config.networking.domain;

  cfg = config.garden.services.buildbot;
in
{
  options.garden.services.buildbot = mkServiceOption "buildbot" { domain = "ci.${rdomain}"; };

  imports = [
    inputs.buildbot-nix.nixosModules.buildbot-master
    inputs.buildbot-nix.nixosModules.buildbot-worker
  ];

  config = mkIf cfg.enable (mkMerge [
    {
      age.secrets = {
        buildbot-worker = mkSecret { file = "buildbot/worker"; };
        buildbot-workers = mkSecret { file = "buildbot/workers"; };
        buildbot-gh-webhook-secret = mkSecret { file = "buildbot/gh-webhook-secret"; };
        buildbot-gh-private-key = mkSecret { file = "buildbot/gh-private-key"; };
        buildbot-gh-oauth = mkSecret { file = "buildbot/gh-oauth"; };
      };

      garden.services = {
        nginx.vhosts.${cfg.domain} = { };
      };

      services.buildbot-nix = {
        master = {
          enable = true;

          inherit (cfg) domain;

          accessMode.public = { };
          useHTTPS = true;

          admins = [ "isabelroses" ];
          workersFile = secrets.buildbot-workers.path;

          pullBased.repositories.infra = {
            url = "https://github.com/isabelroses/dotfiles.git";
            defaultBranch = "main";
          };

          authBackend = "github";
          github = {
            enable = true;
            webhookSecretFile = secrets.buildbot-gh-webhook-secret.path;
            authType.app = {
              id = 1153859;
              secretKeyFile = secrets.buildbot-gh-private-key.path;
            };
            oauthId = "Iv23liSeLy6J7IS9awg1";
            oauthSecretFile = secrets.buildbot-gh-oauth.path;
          };
        };

        worker = {
          enable = true;
          # masterUrl = cfg.domain;
          workerPasswordFile = secrets.buildbot-worker.path;
        };
      };
    }

    (mkIf config.garden.services.attic.enable {
      age.secrets = {
        attic-prod-auth-token = mkSecret { file = "attic/prod-auth-token"; };
        attic-netrc = mkSecret { file = "attic/netrc"; };
      };

      # Add netrc file for this machine to do its normal thing with the cache, as a machine.
      nix.settings.netrc-file = config.age.secrets.attic-netrc.path;

      systemd.services.attic-watch-store = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        environment.HOME = "/var/lib/attic-watch-store";
        serviceConfig = {
          DynamicUser = true;
          MemoryHigh = "5%";
          MemoryMax = "10%";
          LoadCredential = "prod-auth-token:${config.age.secrets.attic-prod-auth-token.path}";
          StateDirectory = "attic-watch-store";
        };
        path = [ pkgs.attic-client ];
        script = ''
          set -eux -o pipefail
          ATTIC_TOKEN=$(< $CREDENTIALS_DIRECTORY/prod-auth-token)
          attic login prod https://${cfg.domain} $ATTIC_TOKEN
          attic use prod
          exec attic watch-store prod:prod
        '';
      };
    })
  ]);
}
