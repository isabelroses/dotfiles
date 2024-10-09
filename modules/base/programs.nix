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
    fish.enable = true;
    zsh.enable = pkgs.stdenv.hostPlatform.isDarwin;

    bash = ldTernary pkgs { promptInit = bashPrompt; } { interactiveShellInit = bashPrompt; };
  };
}
