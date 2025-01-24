{
  lib,
  pkgs,
  config,
  osConfig,
  defaults,
  ...
}:
let
  inherit (lib.lists) optional;
in
{
  home = {
    sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
      # I relocated this too the fish config, such that it would fix a issue where git would use the wrong version
      # "/etc/profiles/per-user/isabel/bin" # needed for darwin
    ] ++ optional pkgs.stdenv.hostPlatform.isDarwin "$GHOSTTY_BIN_DIR";

    sessionVariables = {
      EDITOR = defaults.editor;
      GIT_EDITOR = defaults.editor;
      VISUAL = defaults.editor;
      TERMINAL = defaults.terminal;
      SYSTEMD_PAGERSECURE = "true";
      PAGER = defaults.pager;
      MANPAGER = defaults.manpager;
      FLAKE = osConfig.garden.environment.flakePath;
      NH_FLAKE = osConfig.garden.environment.flakePath;
    };
  };
}
