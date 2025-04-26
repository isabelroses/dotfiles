{ lib, config, ... }:
let
  inherit (lib.modules) mkIf mkOrder;
  inherit (lib.strings) removePrefix;

  cfg = config.garden.programs.zsh;
in
{
  programs.zsh = mkIf cfg.enable {
    enable = true;
    inherit (cfg) package;

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
