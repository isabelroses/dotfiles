{
  config,
  osConfig,
  ...
}:
let
  inherit (config.garden.programs) defaults;
in
{
  home.sessionVariables = {
    EDITOR = defaults.editor;
    GIT_EDITOR = defaults.editor;
    VISUAL = defaults.editor;
    TERMINAL = defaults.terminal;
    SYSTEMD_PAGERSECURE = "true";
    PAGER = defaults.pager;
    MANPAGER = defaults.manpager;
    FLAKE = osConfig.garden.environment.flakePath;
    NH_FLAKE = osConfig.garden.environment.flakePath;
    DO_NOT_TRACK = 1;
  };

  programs.nushell.environmentVariables = config.home.sessionVariables;
}
