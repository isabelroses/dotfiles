{ config, ... }:
{
  # variables that I want to set globally on all systems
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";

    SYSTEMD_PAGERSECURE = "true";
    PAGER = "less -FR";
    MANPAGER = "nvim +Man!";

    # Some programs like `nh` use the FLAKE env var to determine the flake path
    FLAKE = config.garden.environment.flakePath;
    NH_FLAKE = config.garden.environment.flakePath;
  };
}
