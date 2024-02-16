{
  imports = [
    ./devshell.nix # a dev shell that provieds all that you will need to work
    ./deploy-rs.nix # configuration for deploying hosts via deploy-rs
    ./formatter.nix # formatter for nix fmt
    ./treefmt.nix # treefmt is another formatter for every lanauage
    ./pre-commit.nix # pre-commit hooks to help manage the flake
  ];
}
