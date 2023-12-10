{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf isModernShell;
in {
  programs.bash = {
    enable = true;
    bashrcExtra = mkIf (isModernShell osConfig) ''
      eval "$(${lib.getExe pkgs.starship} init bash)"
    '';
    historyFile = "${config.xdg.stateHome}/bash/history";
    historyFileSize = 1000;
    historySize = 100;
    shellOptions = [
      "cdspell"
      "checkjobs"
      "checkwinsize"
      "dirspell"
      "globstar"
      "histappend"
      "no_empty_cmd_completion"
    ];
  };
}
