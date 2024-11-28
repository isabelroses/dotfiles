{ config, osConfig, ... }:
{
  programs.bash = {
    inherit (osConfig.garden.programs.bash) enable package;
    enableCompletion = true;

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
