{
  stdenv,
  mkShellNoCC,

  inputs, # our inputs
  self ? inputs.self,
}:
mkShellNoCC {
  inputsFrom = [ self.packages.${stdenv.hostPlatform.system}.default ];

  packages = [ ];

  shellHook = ''
    echo "Hello, world!"
  '';
}
