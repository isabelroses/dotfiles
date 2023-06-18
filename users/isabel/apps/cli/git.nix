{
  config,
  lib,
  pkgs,
  system,
  ...
}: let
  shouldUseSSH = true;
  ifSSH = c:
    if shouldUseSSH
    then c
    else {};
in {
  programs.git = {
    enable = true;
    inherit (system.git) userEmail userName;
    extraConfig = {
      gpg = {
        format = "ssh";
      };
      url = ifSSH {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };
      init = {
        defaultBranch = "main";
      };
      commit = {
        gpgsign = true;
      };
      tag = {
        gpgsign = true;
      };
      user = {
        signingKey = "/home/${system.currentUser}/.ssh/keys/github/gh2.pub";
      };
    };
  };
}
