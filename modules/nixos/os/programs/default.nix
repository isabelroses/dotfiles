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

    bash.promptInit = mkIf (isModernShell config) ''
      eval "$(${getExe pkgs.starship} init bash)"
    '';

    # home-manager is so strange and needs these declared multiple times
    fish.enable = true;
  };
}
