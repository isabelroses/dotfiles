{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = true;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = true;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };

      # git clients
      "github.com" = {
        user = "git";
        hostname = "github.com";
        identityFile = "~/.ssh/keys.github.id_ed25519";
      };

      "gitlab.com" = {
        user = "git";
        hostname = "gitlab.com";
      };

      "git.isabelroses.com" = {
        user = "git";
        hostname = "git.isabelroses.com";
        port = 2222;
        identityFile = "~/.ssh/keys.gitisabel.id_ed25519";
      };

      "amity" = {
        hostname = "143.47.240.116";
        identityFile = "~/.ssh/keys.amity.id_rsa";
      };
    };
  };
}
