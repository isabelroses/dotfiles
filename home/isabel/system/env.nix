{
  config,
  osConfig,
  defaults,
  ...
}:
{
  home = {
    sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
      # I relocated this too the fish config, such that it would fix a issue where git would use the wrong version
      # "/etc/profiles/per-user/isabel/bin" # needed for darwin
    ];

    sessionVariables = {
      EDITOR = defaults.editor;
      GIT_EDITOR = defaults.editor;
      VISUAL = defaults.editor;
      TERMINAL = defaults.terminal;
      SYSTEMD_PAGERSECURE = "true";
      PAGER = "less -FR";
      FLAKE = osConfig.garden.environment.flakePath;
    };
  };
}
