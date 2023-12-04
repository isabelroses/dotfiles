{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (config.modules) services;
in {
  imports = [inputs.sops.nixosModules.sops];

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
      cloudflared-hydra = mkIf services.cloudflared.enable {
        owner = "cloudflared";
        group = "cloudflared";
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

      mailserver-git-nohash = mkIf services.forgejo.enable {
        owner = "forgejo";
        group = "forgejo";
      };

      isabelroses-web-env = {};

      nextcloud-passwd = mkIf services.nextcloud.enable {
        owner = "nextcloud";
        group = "nextcloud";
      };

      # vaultwarden
      vaultwarden-env = {};

      # miniflux
      miniflux-env = mkIf services.miniflux.enable {
        owner = "miniflux";
        group = "miniflux";
      };

      # matrix
      matrix = mkIf services.matrix.enable {
        owner = "matrix-synapse";
        mode = "400";
      };

      docker-hub = {};

      #wakapi
      wakapi = mkIf services.wakapi.enable {
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
