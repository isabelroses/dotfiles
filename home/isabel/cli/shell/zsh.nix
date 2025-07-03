{ lib, config, ... }:
let
  inherit (lib) mkOrder removePrefix;
in
{
  programs.zsh = {
    autosuggestion.enable = true;
    # enableCompletion = true;
    syntaxHighlighting.enable = true;

    dotDir = (removePrefix (config.home.homeDirectory + "/") config.xdg.configHome) + "/zsh";

    initContent = mkOrder 1000 ''
      function title_precmd_hook() {
        print -Pn "\e]0;$(pwd)\a"
      }
      precmd_functions+=title_precmd_hook
    '';
  };
}
