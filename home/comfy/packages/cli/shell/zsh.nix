{ pkgs, ... }:
{
  programs.zsh = {
    enable = pkgs.stdenv.hostPlatform.isDarwin;

    autosuggestion.enable = true;
    # enableCompletion = true;
    syntaxHighlighting.enable = true;

    dotDir = ".config/zsh";
  };
}
