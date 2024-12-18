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
  inherit (lib.hardware) ldTernary;

  bashPrompt = mkIf (isModernShell config) ''
    eval "$(${getExe pkgs.starship} init bash)"
  '';
in
{
  # home-manager is so strange and needs these declared multiple times
  programs = {
    fish.enable = config.garden.programs.fish.enable;
    zsh.enable = config.garden.programs.zsh.enable;

    bash = ldTernary pkgs { promptInit = bashPrompt; } { interactiveShellInit = bashPrompt; };
  };
}
