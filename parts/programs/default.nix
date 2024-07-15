{
  imports = [
    ./deploy.nix # a setup for deploy-rs, which allows us to remotely build and deploy our flake
    ./formatter.nix # formatter for nix fmt, via treefmt is a formatter for every language
    ./pre-commit.nix # git hooks to help manage the flake
    ./shell.nix # a dev shell that provieds all that you will need to work
  ];
}
