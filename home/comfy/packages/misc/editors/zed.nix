# TODO: module this, depends on
# https://github.com/nix-community/home-manager/pull/5455
{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  cfg = osConfig.garden.programs.zed;
in
{
  home.packages = lib.lists.optionals cfg.enable [ pkgs.zed-editor ];
}
