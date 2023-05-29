{
  config,
  lib,
  pkgs,
  system,
  ...
}: {
  programs.git = {
    enable = true;
    inherit (system.git) userEmail userName;
    extraConfig = {
      gpg = {
        format = "ssh";
      };
      init = {
        defaultBranch = "master";
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
