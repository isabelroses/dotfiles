{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [ inputs.sops.nixosModules.sops ];

  environment.systemPackages = with pkgs; [sops age];

  sops = {
    defaultSopsFile = ./secrets.yaml;

    age.keyFile = "/home/${config.modules.system.mainUser}/.config/sops/age/keys.txt";

    secrets = let
      mainUser = config.modules.system.mainUser;
      homeDir = config.home-manager.users.${mainUser}.home.homeDirectory;
      sshDir = homeDir + "/.ssh";

      ### servers ###
      secretsPath = "/run/secrets.d/";
      mailserverPath = secretsPath + "/mailserver";
    in {
      ### server ###
      cloudflared-hydra = {
        #path = secretsPath + "/cloudflared/hydra";
        owner = mainUser;
        group = "cloudflared";
      };

      # mailserver
      mailserver-isabel.path = mailserverPath + "/isabel";
      mailserver-gitea.path = mailserverPath + "/gitea";
      mailserver-vaultwarden.path = mailserverPath + "/vaultwarden";

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
      # Luz and Edalyn are now dead replaced by bernie
      #luz-key.path = sshDir + "/luz";
      #edalyn-key.path = sshDir + "/edalyn";
      bernie-key = {
        path = sshDir + "/bernie";
        owner = mainUser;
      };
      king-key = { 
        path = sshDir + "/king";
        owner = mainUser;
      };

      # my local servers / clients
      alpha-key = {
        path = sshDir + "/alpha";
        owner = mainUser;
      };
      alpha-key-pub = {
        path = sshDir + "/alpha.pub";
        owner = mainUser;
      };
      hydra-key = {
        path = sshDir + "/hydra";
        owner = mainUser;
      };
      hydra-key-pub = {
        path = sshDir + "/hydra.pub";
        owner = mainUser;
      };
    };
  };
}
