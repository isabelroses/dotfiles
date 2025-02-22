{
  lib,
  self,
  config,
  inputs,
  ...
}:
let
  inherit (self.lib) template;
  inherit (lib.modules) mkIf;
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

  config = mkIf config.garden.services.buildbot.enable {
    age.secrets = {
      buildbot-worker = mkSecret { file = "buildbot/worker"; };
      buildbot-workers = mkSecret { file = "buildbot/workers"; };
      buildbot-gh-webhook-secret = mkSecret { file = "buildbot/gh-webhook-secret"; };
      buildbot-gh-private-key = mkSecret { file = "buildbot/gh-private-key"; };
      buildbot-gh-oauth = mkSecret { file = "buildbot/gh-oauth"; };
    };

    services = {
      buildbot-nix = {
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

      nginx.virtualHosts.${cfg.domain} = template.ssl rdomain;
    };
  };
}
