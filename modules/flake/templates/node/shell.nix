{
  stdenv,
  mkShellNoCC,

  # extra tooling
  eslint_d,
  prettierd,
  typescript,

  inputs, # our inputs
  self ? inputs.self,
}:
mkShellNoCC {
  inputsFrom = [ self.packages.${stdenv.hostPlatform.system}.default ];

  packages = [
    eslint_d
    prettierd
    typescript
  ];

  shellHook = ''
    eslint_d start # start eslint daemon
    eslint_d status # inform user about eslint daemon status
  '';
}
