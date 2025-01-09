{
  stdenv,
  mkShell,

  # extra tooling
  clippy,
  rustfmt,
  rust-analyzer,

  inputs, # our inputs
  self ? inputs.self,
}:
mkShell {
  inputsFrom = [ self.packages.${stdenv.hostPlatform.system}.default ];

  packages = [
    clippy
    rustfmt
    rust-analyzer
  ];
}
