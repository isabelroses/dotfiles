{ lib, config, ... }:
let
  inherit (lib.lists) optional;

  cfg = config.programs;
in
{
  # if a given shell is enabled, add the corresponding completion paths
  environment.pathsToLink =
    [
      "/share/bash-completion"
    ]
    ++ optional cfg.zsh.enable "/share/zsh"
    ++ optional cfg.fish.enable "/share/fish";
}
