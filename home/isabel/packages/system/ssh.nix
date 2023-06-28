_: {
  programs = {
    ssh = {
      enable = true;
      hashKnownHosts = true;
      compression = true;
      matchBlocks = let
        commonIdFile = "~/.ssh/keys/id_ed25519";
      in {
        "aur.archlinux.org" = {
          user = "aur";
          hostname = "aur.archlinux.org";
          identityFile = "~/.ssh/keys/aur/id.key";
        };

        "github.com" = {
          user = "git";
          hostname = "github.com";
          identityFile = "~/.ssh/keys/github/id.key";
        };
      };
    };
  };
}
