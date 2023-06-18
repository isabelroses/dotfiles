{
  config,
  lib,
  pkgs,
  ...
}:
with config;
with lib;
with pkgs; {
  users = {
    defaultUserShell = bash;
    mutableUsers = true;

    users = {
      root = {
        home = "/root";
        uid = ids.uids.root;
        group = "root";
        initialHashedPassword = mkDefault "!";
      };
    };
  };
}