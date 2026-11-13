{
  mkShellNoCC,
  just,
  gitMinimal,
  sops,
  treefmt-wrapped,
}:
mkShellNoCC {
  name = "dotfiles";

  packages = [
    just # quick and easy task runner
    gitMinimal # we need git
    sops # secrets management
    treefmt-wrapped # nix formatter
  ]
  ++ treefmt-wrapped.runtimeInputs; # collect all our formatters

  env.DIRENV_LOG_FORMAT = "";

  meta.description = "Development shell for this configuration";
}
