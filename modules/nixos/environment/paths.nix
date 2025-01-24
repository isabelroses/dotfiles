{ lib, config, ... }:
let
  inherit (lib.lists) optional;

  cfg = config.garden.meta;
in
{
  # if a given shell is enabled, add the corresponding completion paths
  environment.pathsToLink =
    [
      "/share/bash-completion"
    ]
    ++ optional cfg.zsh "/share/zsh"
    ++ optional cfg.fish "/share/fish";
}
