{
  just,
  texlive,
  callPackage,
  ...
}: let
  mainPkg = callPackage ./default.nix {};
in
  mainPkg.overrideAttrs (oa: {
    buildInputs =
      [
        just

        (texlive.combine {
          inherit
            (texlive)
            latexmk
            biblatex
            biber
            pdfpages
            ;
        })
      ]
      ++ (oa.nativeBuildInputs or []);

    TEXMFHOME = "./cache";
    TEXMFVAR = "./cache/var";
  })
