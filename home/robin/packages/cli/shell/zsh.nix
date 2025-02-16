{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.strings) removePrefix;

  cfg = config.garden.programs.zsh;
in
{
  programs.zsh = mkIf cfg.enable {
    enable = true;
    inherit (cfg) package;

    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    dotDir = (removePrefix (config.home.homeDirectory + "/") config.xdg.configHome) + "/zsh";

    history = {
      path = config.xdg.stateHome + "/zsh/history";
    };

    initExtra = ''
      function title_precmd_hook() {
        print -Pn "\e]0;$(pwd)\a"
      }
      precmd_functions+=title_precmd_hook
    '';
  };
}
