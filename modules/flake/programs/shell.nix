{
  mkShellNoCC,
  just,
  gitMinimal,
  sops,
  # nix-output-monitor,
  treefmt-wrapped,
}:
mkShellNoCC {
  name = "dotfiles";

  packages = [
    just # quick and easy task runner
    gitMinimal # we need git
    sops # secrets management
    treefmt-wrapped # nix formatter
    # nix-output-monitor # get clean diff between generations
  ];

  inputsFrom = [ treefmt-wrapped ];

  env.DIRENV_LOG_FORMAT = "";

  meta.description = "Development shell for this configuration";
}
