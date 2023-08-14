{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.sops.homeManagerModules.sops];
  home.packages = with pkgs; [sops age];
  sops = {
    gnupg.home = config.programs.gpg.homedir;
    defaultSopsFile = ./secrets.yaml;

    secrets = let
      homeDir = config.home.homeDirectory;
      sshDir = homeDir + "/.ssh";
    in {
      git-credentials.path = "${homeDir}/.git-credentials";
      cloudflared-hydra.path = "${homeDir}/.secrets/cloudflared";

      # git ssh keys
      gh-key.path = "${sshDir}/github";
      gh-key-pub.path = "${sshDir}/github.pub";
      aur-key.path = "${sshDir}/aur";
      aur-key-pub.path = "${sshDir}/aur.pub";

      # ORACLE vps'
      openvpn-key.path = "${sshDir}/openvpn";
      luz-key.path = "${sshDir}/luz";
      edalyn-key.path = "${sshDir}/edalyn";
      king-key.path = "${sshDir}/king";

      # my local servers / clients
      alpha-key.path = "${sshDir}/.ssh/alpha";
      alpha-key-pub.path = "${sshDir}/alpha.pub";
      hydra-key.path = "${sshDir}/hydra";
      hydra-key-pub.path = "${sshDir}/hydra.pub";
    };
  };
}
