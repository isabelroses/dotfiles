{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
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

      ### servers ###
      secretsPath = "/run/secrets.d";
      mailserverPath = secretsPath + "/mailserver";
    in {
      ### server ###
      cloudflared-hydra = mkIf config.modules.usrEnv.services.cloudflared.enable {
        #path = secretsPath + "/cloudflared/hydra";
        owner = "cloudflared";
        group = "cloudflared";
      };

      # mailserver
      mailserver-isabel.path = mailserverPath + "/isabel";
      mailserver-gitea.path = mailserverPath + "/gitea";
      mailserver-gitea-nohash = mkIf config.modules.usrEnv.services.gitea.enable {
        path = mailserverPath + "/gitea-nohash";
        owner = "git";
        group = "gitea";
      };
      mailserver-vaultwarden.path = mailserverPath + "/vaultwarden";
      mailserver-database.path = mailserverPath + "/database";

      # vaultwarden
      vaultwarden-env.path = secretsPath + "/vaultwarden/env";

      ### user ###
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
