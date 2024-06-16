{
  lib,
  just,
  texlive,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation {
  name = "example-latex";
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

  env = {
    TEXMFHOME = "./cache";
    TEXMFVAR = "./cache/var";
  };

  meta = {
    description = "A example latex project using nix";
    homepage = "https://github.com/isabelroses/example-latex";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ isabelroses ];
    mainPackage = "example";
  };
}
