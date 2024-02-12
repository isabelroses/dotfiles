{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (config.modules) services;
in {
  environment.systemPackages = with pkgs; [sops age];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    # age.keyFile = "/home/${config.modules.system.mainUser}/.config/sops/age/keys.txt";

    secrets = let
      inherit (config.modules.system) mainUser;
      homeDir = config.home-manager.users.${mainUser}.home.homeDirectory;
      sshDir = homeDir + "/.ssh";
    in {
      # server
      cloudflared-hydra = mkIf services.networking.cloudflared.enable {
        owner = "cloudflared";
        group = "cloudflared";
      };

      cloudflare-cert-api = mkIf services.networking.nginx.enable {
        owner = "nginx";
        group = "nginx";
      };

      # mailserver
      rspamd-web = {};
      mailserver-isabel = {};
      mailserver-vaultwarden = {};
      mailserver-database = {};
      mailserver-grafana = {};
      mailserver-git = {};
      mailserver-noreply = {};
      mailserver-spam = {};

      mailserver-grafana-nohash = mkIf services.monitoring.grafana.enable {
        owner = "grafana";
        group = "grafana";
      };

      mailserver-git-nohash = mkIf services.dev.forgejo.enable {
        owner = "forgejo";
        group = "forgejo";
      };

      vikunja-env = mkIf services.vikunja.enable {
        owner = "vikunja-api";
        group = "vikunja-api";
      };

      nextcloud-passwd = mkIf services.media.nextcloud.enable {
        owner = "nextcloud";
        group = "nextcloud";
      };

      # vaultwarden
      vaultwarden-env = {};

      # matrix
      matrix = mkIf services.media.matrix.enable {
        owner = "matrix-synapse";
        mode = "400";
      };

      # plausable
      plausible-key = mkIf services.dev.plausible.enable {
        owner = "plausible";
        group = "plausible";
      };

      plausible-admin = mkIf services.dev.plausible.enable {
        owner = "plausible";
        group = "plausible";
      };

      #wakapi
      wakapi = mkIf services.dev.wakapi.enable {
        owner = "wakapi";
        group = "wakapi";
      };

      wakapi-mailer = mkIf services.dev.wakapi.enable {
        owner = "wakapi";
        group = "wakapi";
      };

      mongodb-passwd = mkIf services.database.mongodb.enable {
        mode = "400";
      };

      # users passwords
      user-isabel-password = {
        neededForUsers = true;
      };
      user-root-password = {
        neededForUsers = true;
      };

      # user
      git-credentials = {
        path = homeDir + "/.git-credentials";
        owner = mainUser;
        group = "users";
      };

      wakatime = {
        path = homeDir + "/.config/wakatime/.wakatime.cfg";
        owner = mainUser;
      };

      # git ssh keys
      gh-key = {
        path = sshDir + "/github";
        owner = mainUser;
      };
      gh-key-pub = {
        path = sshDir + "/github.pub";
        owner = mainUser;
      };
      aur-key = {
        path = sshDir + "/aur";
        owner = mainUser;
      };
      aur-key-pub = {
        path = sshDir + "/aur.pub";
        owner = mainUser;
      };

      # ORACLE vps'
      openvpn-key = {
        path = sshDir + "/openvpn";
        owner = mainUser;
      };
      amity-key = {
        path = sshDir + "/amity";
        owner = mainUser;
      };

      # All nixos machines
      nixos-key = {
        path = sshDir + "/nixos";
        owner = mainUser;
      };
      nixos-key-pub = {
        path = sshDir + "/nixos.pub";
        owner = mainUser;
      };
    };
  };
}
