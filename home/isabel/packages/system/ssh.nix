_: {
  programs = {
    ssh = {
      enable = true;
      hashKnownHosts = true;
      compression = true;
      matchBlocks = let
        commonIdFile = "~/.ssh/id_ed25519";
      in {
        "aur" = {
          hostname = "aur.archlinux.org";
          identityFile = "~/.ssh/aur";
        };

        "builder" = {
          hostname = "build.neushore.dev";
          user = "builder";
          identityFile = "~/.ssh/builder";
          port = 30;
        };

        "nix-builder" = {
          hostname = "helios";
          user = "nix-builder";
          identityFile = "~/.ssh/builder";
        };

        "frozendev" = {
          hostname = "frzn.dev";
          user = "raf";
          identityFile = "~/.ssh/id_rsa";
        };

        "notavps" = {
          hostname = "cloud.notashelf.dev";
          user = "notashelf";
          identityFile = "~/.ssh/notavps";
          port = 2214;
        };

        "github" = {
          hostname = "github.com";
          identityFile = "~/.ssh/github_rsa";
        };

        "neushore" = {
          hostname = "ssh.neushore.dev";
          user = "raf";
          identityFile = "~/.ssh/neushore";
          port = 30;
        };
      };
    };
  };
}
