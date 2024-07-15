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
    less.enable = true;

    bash.promptInit = mkIf (isModernShell config) ''
      eval "$(${getExe pkgs.starship} init bash)"
    '';

    # home-manager is so strange and needs these declared multiple times
    fish.enable = true;
  };
}
