{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.lists) optional;
in
{
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ]
  ++ optional pkgs.stdenv.hostPlatform.isDarwin "$GHOSTTY_BIN_DIR";
}
