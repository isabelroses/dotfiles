{
  stdenv,
  mkShellNoCC,

  # extra tooling
  go,
  gopls,
  goreleaser,

  inputs, # our inputs
  self ? inputs.self,
}:
mkShellNoCC {
  inputsFrom = [ self.packages.${stdenv.hostPlatform.system}.default ];

  packages = [
    go
    gopls
    goreleaser
  ];
}
