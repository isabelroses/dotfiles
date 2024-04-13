{
  imports = [
    ./formatter.nix # formatter for nix fmt, via treefmt is a formatter for every language
    ./pre-commit.nix # git hooks to help manage the flake
    ./shell.nix # a dev shell that provieds all that you will need to work
  ];
}
