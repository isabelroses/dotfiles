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
    # I relocated this too the fish config, such that it would fix a issue where git would use the wrong version
    # "/etc/profiles/per-user/isabel/bin" # needed for darwin
  ] ++ optional pkgs.stdenv.hostPlatform.isDarwin "$GHOSTTY_BIN_DIR";
}
