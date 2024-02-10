{pkgs, ...}: {
  programs.zsh = {
    enable = pkgs.stdenv.isDarwin;

    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    dotDir = ".config/zsh";
  };
}
