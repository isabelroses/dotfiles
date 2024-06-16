{
  just,
  texlive,
  callPackage,
  ...
}:
let
  mainPkg = callPackage ./default.nix { };
in
mainPkg.overrideAttrs (oa: {
  buildInputs = [
    just

    (texlive.combine {
      inherit (texlive)
        scheme-medium
        biblatex
        biber
        pdfpages
        ;
    })
  ] ++ (oa.nativeBuildInputs or [ ]);
})
