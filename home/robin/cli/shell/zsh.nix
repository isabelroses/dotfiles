{ lib, config, ... }:
let
  inherit (lib) mkDefault mkOrder;
in
{
  programs.zsh = {
    enable = mkDefault (config.garden.programs.defaults.shell == "zsh");
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    dotDir = "${config.xdg.configHome}/zsh";

    history = {
      path = config.xdg.stateHome + "/zsh/history";
    };

    initContent = mkOrder 1000 (
      ''
        function title_precmd_hook() {
          print -Pn "\e]0;$(pwd)\a"
        }
        precmd_functions+=title_precmd_hook
      ''
      + ''
        setopt autopushd
      ''
    );
  };
}
