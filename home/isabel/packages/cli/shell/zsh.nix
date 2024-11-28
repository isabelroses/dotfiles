{ lib, osConfig, ... }:
let
  inherit (lib.modules) mkIf;

  cfg = osConfig.garden.programs.zsh;
in
{
  programs.zsh = mkIf cfg.enable {
    enable = true;
    inherit (cfg) package;

    autosuggestion.enable = true;
    # enableCompletion = true;
    syntaxHighlighting.enable = true;

    dotDir = ".config/zsh";
  };
}
