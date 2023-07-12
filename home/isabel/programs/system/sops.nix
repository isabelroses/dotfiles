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
    secrets = {
      git-credentials.path = "${config.home.homeDirectory}/.git-credentials";

      # git ssh keys
      gh-key.path = "${config.home.homeDirectory}/.ssh/github";
      gh-key-pub.path = "${config.home.homeDirectory}/.ssh/github.pub";
      aur-key.path = "${config.home.homeDirectory}/.ssh/aur";
      aur-key-pub.path = "${config.home.homeDirectory}/.ssh/aur.pub";

      # ORACLE vps'
      openvpn-key.path = "${config.home.homeDirectory}/.ssh/openvpn";
      luz-key.path = "${config.home.homeDirectory}/.ssh/luz";
      edalyn-key.path = "${config.home.homeDirectory}/.ssh/edalyn";
      king-key.path = "${config.home.homeDirectory}/.ssh/king";

      # my local servers / clients
      alpha-key.path = "${config.home.homeDirectory}/.ssh/alpha";
      alpha-key-pub.path = "${config.home.homeDirectory}/.ssh/alpha.pub";
      hydra-key.path = "${config.home.homeDirectory}/.ssh/hydra";
      hydra-key-pub.path = "${config.home.homeDirectory}/.ssh/hydra.pub";
    };
  };
}
