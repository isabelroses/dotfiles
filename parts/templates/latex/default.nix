{
  just,
  texlive,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation {
  name = "miq-doc";
  nativeBuildInputs = [
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

  src = ./.;

  buildPhase = ''
    runHook preBuild
    just build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -vL out/index.pdf $out
    runHook postInstall
  '';

  TEXMFHOME = "./cache";
  TEXMFVAR = "./cache/var";
}
