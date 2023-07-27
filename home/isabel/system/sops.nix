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
      homedir = config.home.homeDirectory;
    in {
      git-credentials.path = "${homedir}/.git-credentials";

      # git ssh keys
      gh-key.path = "${homedir}/.ssh/github";
      gh-key-pub.path = "${homedir}/.ssh/github.pub";
      aur-key.path = "${homedir}/.ssh/aur";
      aur-key-pub.path = "${homedir}/.ssh/aur.pub";

      # ORACLE vps'
      openvpn-key.path = "${homedir}/.ssh/openvpn";
      luz-key.path = "${homedir}/.ssh/luz";
      edalyn-key.path = "${homedir}/.ssh/edalyn";
      king-key.path = "${homedir}/.ssh/king";

      # my local servers / clients
      alpha-key.path = "${homedir}/.ssh/alpha";
      alpha-key-pub.path = "${homedir}/.ssh/alpha.pub";
      hydra-key.path = "${homedir}/.ssh/hydra";
      hydra-key-pub.path = "${homedir}/.ssh/hydra.pub";
    };
  };
}
