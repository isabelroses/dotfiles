{ lib, ... }:
let
  inherit (lib.lists) optional;
in
{
  # if a given shell is enabled, add the corresponding completion paths
  environment.pathsToLink =
    [
      "/share/bash-completion"
    ]
    ++ optional false "/share/zsh"
    ++ optional true "/share/fish";
}
