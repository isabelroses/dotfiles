{
  mkShellNoCC,
  just,
  gitMinimal,
  sops,
  npins,
  nix-output-monitor,
  treefmt-wrapped,
}:
mkShellNoCC {
  name = "dotfiles";

  packages = [
    just # quick and easy task runner
    gitMinimal # we need git
    sops # secrets management
    treefmt-wrapped # nix formatter
    npins
    nix-output-monitor # get clean diff between generations
  ]
  ++ treefmt-wrapped.runtimeInputs; # collect all our formatters

  env.DIRENV_LOG_FORMAT = "";

  meta.description = "Development shell for this configuration";
}
