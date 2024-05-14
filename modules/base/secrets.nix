{
  lib,
  self,
  pkgs,
  config,
  inputs,
  inputs',
  ...
}:
let
  inherit (lib) mkIf ldTernary;
  inherit (config.modules) services;
  inherit (pkgs.stdenv) isDarwin;

  inherit (config.modules.system) mainUser;
  homeDir = config.home-manager.users.${mainUser}.home.homeDirectory;
  sshDir = homeDir + "/.ssh";

  userGroup = ldTernary pkgs "users" "admin";

  mkSecret =
    cond:
    {
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

  mkSecretWithPath =
    cond:
    {
      file,
      path,
      owner ? "root",
      group ? ldTernary pkgs "root" "admin",
      mode ? "400",
      ...
    }:
    mkIf cond {
      file = "${self}/secrets/${file}.age";
      inherit
        path
        owner
        group
        mode
        ;
    };
in
{
  imports = [ inputs.agenix.nixosModules.default ];

  environment.systemPackages = [ inputs'.agenix.packages.default ];

  age = {
    identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      "${sshDir}/id_ed25519"
    ];

    secretsDir = mkIf isDarwin "/private/tmp/agenix";
    secretsMountPoint = mkIf isDarwin "/private/tmp/agenix.d";

    secrets = {
      wakatime = mkSecretWithPath true {
        file = "wakatime";
        path = homeDir + "/.config/wakatime/.wakatime.cfg";
        owner = mainUser;
        group = userGroup;
      };

      # git ssh keys
      keys-gh = mkSecret true {
        file = "keys/gh";
        owner = mainUser;
        group = userGroup;
      };
      keys-gh-pub = mkSecret true {
        file = "keys/gh-pub";
        owner = mainUser;
        group = userGroup;
      };
      keys-aur = mkSecret true {
        file = "keys/aur";
        owner = mainUser;
        group = userGroup;
      };
      keys-aur-pub = mkSecret true {
        file = "keys/aur-pub";
        owner = mainUser;
        group = userGroup;
      };

      # ORACLE vps'
      keys-openvpn = mkSecret true {
        file = "keys/openvpn";
        owner = mainUser;
        group = userGroup;
      };
      keys-amity = mkSecret true {
        file = "keys/amity";
        owner = mainUser;
        group = userGroup;
      };

      # All nixos machines
      keys-nixos = mkSecretWithPath true {
        file = "keys/nixos";
        path = sshDir + "/id_ed25519";
        owner = mainUser;
        group = userGroup;
      };
      keys-nixos-pub = mkSecretWithPath true {
        file = "keys/nixos-pub";
        path = sshDir + "/id_ed25519.pub";
        owner = mainUser;
        group = userGroup;
      };

      cloudflared-hydra = mkSecret services.networking.cloudflared.enable {
        file = "cloudflare/hydra";
        owner = "cloudflared";
        group = "cloudflared";
      };

      cloudflare-cert-api = mkSecret services.networking.nginx.enable {
        file = "cloudflare/cert-api";
        owner = "nginx";
        group = "nginx";
      };

      # mailserver
      mailserver-isabel = mkSecret services.mailserver.enable { file = "mailserver/isabel"; };
      mailserver-vaultwarden = mkSecret services.mailserver.enable { file = "mailserver/vaultwarden"; };
      mailserver-database = mkSecret services.mailserver.enable { file = "mailserver/database"; };
      mailserver-grafana = mkSecret services.mailserver.enable { file = "mailserver/grafana"; };
      mailserver-git = mkSecret services.mailserver.enable { file = "mailserver/git"; };
      mailserver-noreply = mkSecret services.mailserver.enable { file = "mailserver/noreply"; };
      mailserver-spam = mkSecret services.mailserver.enable { file = "mailserver/spam"; };

      mailserver-grafana-nohash = mkSecret services.monitoring.grafana.enable {
        file = "mailserver/grafana-nohash";
        owner = "grafana";
        group = "grafana";
      };

      mailserver-git-nohash = mkSecret services.dev.forgejo.enable {
        file = "mailserver/git-nohash";
        owner = "forgejo";
        group = "forgejo";
      };

      grafana-oauth2 = mkSecret services.monitoring.grafana.enable {
        file = "grafana-oauth2";
        owner = "grafana";
        group = "grafana";
      };

      blahaj-env = mkSecret services.blahaj.enable { file = "blahaj-env"; };

      vikunja-env = mkSecret services.vikunja.enable {
        file = "vikunja-env";
        owner = "vikunja";
        group = "vikunja";
      };

      nextcloud-passwd = mkSecret services.media.nextcloud.enable {
        file = "nextcloud-passwd";
        owner = "nextcloud";
        group = "nextcloud";
      };

      # vaultwarden
      vaultwarden-env = mkSecret services.vaultwarden.enable {
        file = "vaultwarden-env";
        owner = "vaultwarden";
        group = "vaultwarden";
      };

      # matrix
      matrix = mkSecret services.media.matrix.enable {
        file = "matrix/env";
        owner = "matrix-synapse";
      };

      matrix-sync = mkSecret services.media.matrix.enable {
        file = "matrix/sync";
        owner = "matrix-synapse";
      };

      # plausible
      plausible-key = mkSecret services.dev.plausible.enable {
        file = "plausible/key";
        owner = "plausible";
        group = "plausible";
      };

      plausible-admin = mkSecret services.dev.plausible.enable {
        file = "plausible/admin";
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

      mongodb-passwd = mkSecret services.database.mongodb.enable { file = "mongodb-passwd"; };
    };
  };
}
