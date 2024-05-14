{ osConfig, defaults, ... }:
{
  home.sessionVariables = {
    EDITOR = defaults.editor;
    GIT_EDITOR = defaults.editor;
    VISUAL = defaults.editor;
    TERMINAL = defaults.terminal;
    SYSTEMD_PAGERSECURE = "true";
    PAGER = "less -FR";
    FLAKE = "${osConfig.modules.environment.flakePath}";
    PACE_HOME = "/home/isabel/.config/pace";
  };
}
