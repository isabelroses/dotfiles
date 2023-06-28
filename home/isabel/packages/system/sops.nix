{config, ...}: {
  sops = {
    gnupg.home = config.programs.gpg.homedir;
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      git-credentials = {
        path = "${config.home.homeDirectory}/.git-credentials"
      };
      gh-key = {
        path = "${config.home.homeDirectory}/.ssh/keys/github/gh";
      };
      gh-key-pub = {
        path = "${config.home.homeDirectory}/.ssh/keys/github/gh.pub";
      };
    };
  };
}
