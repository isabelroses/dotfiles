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

    age.keyFile = "/home/${config.modules.system.mainUser}/.config/sops/age/keys.txt";

    secrets = let
      inherit (config.modules.system) mainUser;
      homeDir = config.home-manager.users.${mainUser}.home.homeDirectory;
      sshDir = homeDir + "/.ssh";

      # servers
      secretsPath = "/run/secrets.d";
      mailserverPath = secretsPath + "/mailserver";
    in {
      # server
      cloudflared-hydra = mkIf services.cloudflared.enable {
        #path = secretsPath + "/cloudflared/hydra";
        owner = "cloudflared";
        group = "cloudflared";
      };

      # mailserver
      mailserver-isabel.path = mailserverPath + "/isabel";
      mailserver-vaultwarden.path = mailserverPath + "/vaultwarden";
      mailserver-database.path = mailserverPath + "/database";

      rspamd-web.path = mailserverPath + "/rspamd-auth-file";

      mailserver-grafana.path = mailserverPath + "/grafana";
      mailserver-grafana-nohash = mkIf services.monitoring.grafana.enable {
        path = mailserverPath + "/grafana-nohash";
        owner = "grafana";
        group = "grafana";
      };

      mailserver-gitea.path = mailserverPath + "/gitea";
      mailserver-gitea-nohash = mkIf services.gitea.enable {
        path = mailserverPath + "/gitea-nohash";
        owner = "git";
        group = "git";
      };

      # vaultwarden
      vaultwarden-env.path = secretsPath + "/vaultwarden/env";

      # miniflux
      miniflux-env = mkIf services.miniflux.enable {
        path = secretsPath + "/mini/env";
        owner = "miniflux";
        group = "miniflux";
      };

      # matrix
      matrix = mkIf services.matrix.enable {
        path = secretsPath + "/matrix";
        owner = "matrix-synapse";
        mode = "400";
      };

      #wakapi
      wakapi = mkIf services.wakapi.enable {
        path = secretsPath + "/wakapi/default";
        owner = "wakapi";
        group = "wakapi";
      };

      mongodb-passwd = mkIf services.database.mongodb.enable {
        path = secretsPath + "/mongodb/passwd";
        mode = "400";
      };

      # user
      git-credentials = {
        path = homeDir + "/.git-credentials";
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
      king-key = {
        path = sshDir + "/king";
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

      # my local servers / clients
      /*
      alpha-key = {
        path = sshDir + "/alpha";
        owner = mainUser;
      };
      alpha-key-pub = {
        path = sshDir + "/alpha.pub";
        owner = mainUser;
      };
      */
    };
  };
}
