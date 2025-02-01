{
  imports = [
    ./deploy.nix # a setup for deploy-rs, which allows us to remotely build and deploy our flake
    ./formatter.nix # formatter for nix fmt, via treefmt is a formatter for every language
    ./shell.nix # a dev shell that provieds all that you will need to work
  ];
}
