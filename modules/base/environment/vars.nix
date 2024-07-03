{ config, ... }:
{
  # variables that I want to set globally on all systems
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "vscode";
    SUDO_EDITOR = "nvim";

    SYSTEMD_PAGERSECURE = "true";
    PAGER = "less -FR";
    MANPAGER = "nvim +Man!";

    FLAKE = "${config.garden.environment.flakePath}";
  };
}
