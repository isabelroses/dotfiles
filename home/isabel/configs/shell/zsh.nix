{ pkgs, ... }:
{
  programs.zsh = {
    enable = pkgs.stdenv.isDarwin;

    autosuggestion.enable = true;
    # enableCompletion = true;
    syntaxHighlighting.enable = true;

    dotDir = ".config/zsh";
  };
}
