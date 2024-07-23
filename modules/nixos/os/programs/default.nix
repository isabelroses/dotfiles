{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.meta) getExe;
  inherit (lib.validators) isModernShell;
in
{
  programs = {
    # less pager
    less = {
      enable = true;
      lessopen = null; # don't install perl thanks
    };

    # disable command-not-found, it doesn't help, and it adds perl
    # which we don't need, and we know when we don't have a command anyway
    command-not-found.enable = false;

    bash.promptInit = mkIf (isModernShell config) ''
      eval "$(${getExe pkgs.starship} init bash)"
    '';

    # home-manager is so strange and needs these declared multiple times
    fish.enable = true;
  };

  # disable stub-ld, this exists to kill dynamically linked executables, since they cannot work
  # on NixOS, however we know that so we don't need to see the warning
  environment.stub-ld.enable = false;
}
