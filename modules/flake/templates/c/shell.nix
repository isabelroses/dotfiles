{
  stdenv,
  mkShellNoCC,

  # extra tooling
  libcxx,
  gnumake,
  cppcheck,
  clang-tools,

  inputs, # our inputs
  self ? inputs.self,
}:
mkShellNoCC {
  inputsFrom = [ self.packages.${stdenv.hostPlatform.system}.default ];

  packages = [
    libcxx # stdlib for cpp
    gnumake # builder
    cppcheck # static analysis
    clang-tools # fix headers not found
  ];
}
