{ config, ... }:
let
  inherit (config.garden.programs) defaults;
in
{
  # variables that I want to set globally on all systems
  environment.variables = {
    EDITOR = defaults.editor;
    VISUAL = defaults.editor;
    SUDO_EDITOR = defaults.editor;

    SYSTEMD_PAGERSECURE = "true";
    PAGER = defaults.pager;
    MANPAGER = defaults.manpager;

    # Some programs like `nh` use the FLAKE env var to determine the flake path
    FLAKE = config.garden.environment.flakePath;
    NH_FLAKE = config.garden.environment.flakePath;
  };
}
