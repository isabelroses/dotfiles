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
    path,
    owner ? "root",
    group ? ldTernary pkgs "root" "admin",
    mode ? "400",
  }:
    mkIf cond {
      file = "${self}/secrets/${file}";
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
        git-credentials = mkSecret true {
          file = "git-credentials.age";
          path = homeDir + "/.git-credentials";
          owner = mainUser;
          group = userGroup;
        };

        wakatime = mkSecret true {
          file = "wakatime.age";
          path = homeDir + "/.config/wakatime/.wakatime.cfg";
          owner = mainUser;
          group = userGroup;
        };

        # git ssh keys
        gh-key = mkSecret true {
          file = "gh-key.age";
          path = sshDir + "/github";
          owner = mainUser;
          group = userGroup;
        };
        gh-key-pub = mkSecret true {
          file = "gh-key-pub.age";
          path = sshDir + "/github.pub";
          owner = mainUser;
          group = userGroup;
        };
        aur-key = mkSecret true {
          file = "aur-key.age";
          path = sshDir + "/aur";
          owner = mainUser;
          group = userGroup;
        };
        aur-key-pub = mkSecret true {
          file = "aur-key-pub.age";
          path = sshDir + "/aur.pub";
          owner = mainUser;
          group = userGroup;
        };

        # ORACLE vps'
        openvpn-key = mkSecret true {
          file = "openvpn-key.age";
          path = sshDir + "/openvpn";
          owner = mainUser;
          group = userGroup;
        };
        amity-key = mkSecret true {
          file = "amity-key.age";
          path = sshDir + "/amity";
          owner = mainUser;
          group = userGroup;
        };

        # All nixos machines
        nixos-key = mkSecret true {
          file = "nixos-key.age";
          path = sshDir + "/id_ed25519";
          owner = mainUser;
          group = userGroup;
        };
        nixos-key-pub = mkSecret true {
          file = "nixos-key-pub.age";
          path = sshDir + "/id_ed25519.pub";
          owner = mainUser;
          group = userGroup;
        };
      }

      # server
      (mkIf (builtins.elem device.type ["server" "hybrid"]) {
        cloudflared-hydra = mkSecret services.networking.cloudflared.enable {
          file = "cloudflared-hydra.age";
          owner = "cloudflared";
          group = "cloudflared";
        };

        cloudflare-cert-api = mkIf services.networking.nginx.enable {
          file = "cloudflare-cert-api.age";
          owner = "nginx";
          group = "nginx";
        };

        # mailserver
        mailserver-isabel = mkSecret true {file = "mailserver-isabel.age";};
        mailserver-vaultwarden = mkSecret true {file = "mailserver-vaultwarden.age";};
        mailserver-database = mkSecret true {file = "mailserver-database.age";};
        mailserver-grafana = mkSecret true {file = "mailserver-grafana.age";};
        mailserver-git = mkSecret true {file = "mailserver-git.age";};
        mailserver-noreply = mkSecret true {file = "mailserver-noreply.age";};
        mailserver-spam = mkSecret true {file = "mailserver-spam.age";};

        mailserver-grafana-nohash = mkSecret services.monitoring.grafana.enable {
          file = "mailserver-grafana-nohash.age";
          owner = "grafana";
          group = "grafana";
        };

        mailserver-git-nohash = mkSecret services.dev.forgejo.enable {
          file = "mailserver-git-nohash.age";
          owner = "forgejo";
          group = "forgejo";
        };

        vikunja-env = mkSecret services.vikunja.enable {
          file = "vikunja-env.age";
          owner = "vikunja-api";
          group = "vikunja-api";
        };

        nextcloud-passwd = mkSecret services.media.nextcloud.enable {
          file = "nextcloud-passwd.age";
          owner = "nextcloud";
          group = "nextcloud";
        };

        # vaultwarden
        vaultwarden-env = mkSecret {
          file = "vaultwarden-env.age";
        };

        # matrix
        matrix = mkSecret services.media.matrix.enable {
          file = "matrix.age";
          owner = "matrix-synapse";
        };

        # plausable
        plausible-key = mkSecret services.dev.plausible.enable {
          file = "plausible-key.age";
          owner = "plausible";
          group = "plausible";
        };

        plausible-admin = mkSecret services.dev.plausible.enable {
          file = "plausible-admin.age";
          owner = "plausible";
          group = "plausible";
        };

        #wakapi
        wakapi = mkSecret services.dev.wakapi.enable {
          file = "wakapi.age";
          owner = "wakapi";
          group = "wakapi";
        };

        wakapi-mailer = mkSecret services.dev.wakapi.enable {
          file = "wakapi-mailer.age";
          owner = "wakapi";
          group = "wakapi";
        };

        mongodb-passwd = mkSecret services.database.mongodb.enable {
          file = "mongodb-passwd.age";
        };
      })
    ];
  };
}
