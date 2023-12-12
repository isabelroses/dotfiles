{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf isModernShell;
in {
  programs = {
    bash = {
      promptInit = mkIf (isModernShell config) ''
        eval "$(${lib.getExe pkgs.starship} init bash)"
      '';
    };
    # less pager
    less.enable = true;

    fish.enable = true;
  };
}
