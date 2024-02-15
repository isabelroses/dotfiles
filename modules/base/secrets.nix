{
  lib,
  self,
  pkgs,
  config,
  inputs,
  inputs',
  ...
}: let
  inherit (lib) mkIf mkMerge ldTernary;
  inherit (config.modules) services;
  inherit (pkgs.stdenv) isDarwin;

  inherit (config.modules) device;
  inherit (config.modules.system) mainUser;
  homeDir = config.home-manager.users.${mainUser}.home.homeDirectory;
  sshDir = homeDir + "/.ssh";

  userGroup = ldTernary pkgs "users" "admin";

  mkSecret = cond: {
    file,
    owner ? "root",
    group ? ldTernary pkgs "root" "admin",
    mode ? "400",
    ...
  }:
    mkIf cond {
      file = "${self}/secrets/${file}.age";
      inherit owner group mode;
    };

  mkSecretWithPath = cond: {
    file,
    path,
    owner ? "root",
    group ? ldTernary pkgs "root" "admin",
    mode ? "400",
    ...
  }:
    mkIf cond {
      file = "${self}/secrets/${file}.age";
      inherit path owner group mode;
    };
in {
  imports = [inputs.agenix.nixosModules.default];

  environment.systemPackages = [inputs'.agenix.packages.default];

  age = {
    identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      "${sshDir}/id_ed25519"
    ];

    secretsDir = mkIf isDarwin "/private/tmp/agenix";
    secretsMountPoint = mkIf isDarwin "/private/tmp/agenix.d";

    secrets = mkMerge [
      {
        git-credentials = mkSecretWithPath true {
          file = "git-credentials";
          path = homeDir + "/.git-credentials";
          owner = mainUser;
          group = userGroup;
        };

        wakatime = mkSecretWithPath true {
          file = "wakatime";
          path = homeDir + "/.config/wakatime/.wakatime.cfg";
          owner = mainUser;
          group = userGroup;
        };

        # git ssh keys
        gh-key = mkSecret true {
          file = "gh-key";
          owner = mainUser;
          group = userGroup;
        };
        gh-key-pub = mkSecret true {
          file = "gh-key-pub";
          owner = mainUser;
          group = userGroup;
        };
        aur-key = mkSecret true {
          file = "aur-key";
          owner = mainUser;
          group = userGroup;
        };
        aur-key-pub = mkSecret true {
          file = "aur-key-pub";
          owner = mainUser;
          group = userGroup;
        };

        # ORACLE vps'
        openvpn-key = mkSecret true {
          file = "openvpn-key";
          owner = mainUser;
          group = userGroup;
        };
        amity-key = mkSecret true {
          file = "amity-key";
          owner = mainUser;
          group = userGroup;
        };

        # All nixos machines
        nixos-key = mkSecretWithPath true {
          file = "nixos-key";
          path = sshDir + "/id_ed25519";
          owner = mainUser;
          group = userGroup;
        };
        nixos-key-pub = mkSecretWithPath true {
          file = "nixos-key-pub";
          path = sshDir + "/id_ed25519.pub";
          owner = mainUser;
          group = userGroup;
        };
      }

      # server
      (mkIf (builtins.elem device.type ["server" "hybrid"]) {
        cloudflared-hydra = mkSecret services.networking.cloudflared.enable {
          file = "cloudflared-hydra";
          owner = "cloudflared";
          group = "cloudflared";
        };

        cloudflare-cert-api = mkSecret services.networking.nginx.enable {
          file = "cloudflare-cert-api";
          owner = "nginx";
          group = "nginx";
        };

        # mailserver
        mailserver-isabel = mkSecret true {file = "mailserver-isabel";};
        mailserver-vaultwarden = mkSecret true {file = "mailserver-vaultwarden";};
        mailserver-database = mkSecret true {file = "mailserver-database";};
        mailserver-grafana = mkSecret true {file = "mailserver-grafana";};
        mailserver-git = mkSecret true {file = "mailserver-git";};
        mailserver-noreply = mkSecret true {file = "mailserver-noreply";};
        mailserver-spam = mkSecret true {file = "mailserver-spam";};

        mailserver-grafana-nohash = mkSecret services.monitoring.grafana.enable {
          file = "mailserver-grafana-nohash";
          owner = "grafana";
          group = "grafana";
        };

        mailserver-git-nohash = mkSecret services.dev.forgejo.enable {
          file = "mailserver-git-nohash";
          owner = "forgejo";
          group = "forgejo";
        };

        vikunja-env = mkSecret services.vikunja.enable {
          file = "vikunja-env";
          owner = "vikunja-api";
          group = "vikunja-api";
        };

        nextcloud-passwd = mkSecret services.media.nextcloud.enable {
          file = "nextcloud-passwd";
          owner = "nextcloud";
          group = "nextcloud";
        };

        # vaultwarden
        vaultwarden-env = mkSecret services.vaultwarden.enable {
          file = "vaultwarden-env";
        };

        # matrix
        matrix = mkSecret services.media.matrix.enable {
          file = "matrix";
          owner = "matrix-synapse";
        };

        # plausable
        plausible-key = mkSecret services.dev.plausible.enable {
          file = "plausible-key";
          owner = "plausible";
          group = "plausible";
        };

        plausible-admin = mkSecret services.dev.plausible.enable {
          file = "plausible-admin";
          owner = "plausible";
          group = "plausible";
        };

        #wakapi
        wakapi = mkSecret services.dev.wakapi.enable {
          file = "wakapi";
          owner = "wakapi";
          group = "wakapi";
        };

        wakapi-mailer = mkSecret services.dev.wakapi.enable {
          file = "wakapi-mailer";
          owner = "wakapi";
          group = "wakapi";
        };

        mongodb-passwd = mkSecret services.database.mongodb.enable {
          file = "mongodb-passwd";
        };
      })
    ];
  };
}
