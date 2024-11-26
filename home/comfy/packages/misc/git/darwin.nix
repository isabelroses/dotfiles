{ lib, pkgs, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.hm.dag) entryBefore;
in
{
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  config.home.activation = mkIf pkgs.stdenv.hostPlatform.isDarwin {
    removeExistingGitconfig = entryBefore [ "checkLinkTargets" ] ''
      rm -f ~/.gitconfig
    '';
  };
}
