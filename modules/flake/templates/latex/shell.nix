{
  stdenv,
  mkShellNoCC,

  # extra tooling
  just,
  texlive,

  inputs, # our inputs
  self ? inputs.self,
}:
mkShellNoCC {
  inputsFrom = [ self.packages.${stdenv.hostPlatform.system}.default ];

  packages = [
    just

    (texlive.combine {
      inherit (texlive)
        scheme-medium
        biblatex
        biber
        pdfpages
        ;
    })
  ];

  shellHook = ''
    echo "Hello, world!"
  '';
}
