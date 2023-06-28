{config, ...}: {
  sops = {
    gnupg.home = config.programs.gpg.homedir;
    defaultSopsFile = ../../../../secrets/secrets.yaml;
    secrets = {
      "gh-key" = {
        path = "${config.home.homeDirectory}/.ssh/keys/github/gh";
      };
      "gh-key-pub" = {
        path = "${config.home.homeDirectory}/.ssh/keys/github/gh.pub";
      };
    };
  };
}
