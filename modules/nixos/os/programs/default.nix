{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf isModernShell;
in
{
  programs = {
    # less pager
    less.enable = true;

    bash.promptInit = mkIf (isModernShell config) ''
      eval "$(${lib.getExe pkgs.starship} init bash)"
    '';

    # home-manager is so strange and needs these declared multiple times
    fish.enable = true;
    zsh.enable = pkgs.stdenv.isDarwin;
  };
}
