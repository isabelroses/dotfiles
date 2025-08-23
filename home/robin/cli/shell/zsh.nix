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
        cd-rotate(){
          () {
            builtin emulate -L zsh
            while (( $#dirstack )) && ! builtin pushd -q $1 &>/dev/null; do
              builtin popd -q $1
            done
            (( $#dirstack ))
          } "$@" && builtin zle reset-prompt;
        }
        cd-back(){ cd-rotate -0; }
        cd-forward(){ cd-rotate +1; }
        builtin zle -N cd-back
        builtin zle -N cd-forward
        bindkey "^[[1;3D" cd-forward
        bindkey "^[[1;3C" cd-back
      ''
      + ''
        setopt autopushd
      ''
    );
  };
}
