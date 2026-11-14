{
  callPackage,
  self,
}:
callPackage ./mk-test-check.nix { } "nix-flake-tests" {
  testJournalJail = {
    expr = self.lib.fail2ban.journalJail "forgejo" [ "a <ADDR>" "b <ADDR>" ] { maxretry = 10; };
    expected = {
      filter.Definition = {
        failregex = "a <ADDR>\n    b <ADDR>";
        ignoreregex = "";
      };
      settings = {
        port = "http,https";
        protocol = "tcp,udp";
        journalmatch = "_SYSTEMD_UNIT=forgejo.service";
        maxretry = 10;
      };
    };
  };

  testGiturl = {
    expr = self.lib.helpers.giturl {
      domain = "github.com";
      alias = "gh";
    };
    expected = {
      "https://github.com/".insteadOf = "gh:";
      "ssh://git@github.com/".pushInsteadOf = "gh:";
    };
  };

  testMkPub = {
    expr = self.lib.helpers.mkPub "github.com" {
      type = "rsa";
      key = "AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
    };
    expected = {
      "github.com-rsa" = {
        hostNames = [ "github.com" ];
        publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
      };
    };
  };
}
