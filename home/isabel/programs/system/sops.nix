{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [sops age];
  sops = {
    gnupg.home = config.programs.gpg.homedir;
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      git-credentials.path = "${config.home.homeDirectory}/.git-credentials";

      # github ssh keys
      gh-key.path = "${config.home.homeDirectory}/.ssh/keys/github/id.key";
      gh-key-pub.path = "${config.home.homeDirectory}/.ssh/keys/github/id.pub";
    };
  };
}
