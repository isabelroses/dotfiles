{ lib, pkgs, ... }:
{
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  config.home.activation = lib.mkIf pkgs.stdenv.isDarwin {
    removeExistingGitconfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      rm -f ~/.gitconfig
    '';
  };
}
