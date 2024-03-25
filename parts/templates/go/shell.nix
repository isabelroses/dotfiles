{
  go,
  gopls,
  goreleaser,
  callPackage,
}: let
  mainPkg = callPackage ./default.nix {};
in
  mainPkg.overrideAttrs (oa: {
    nativeBuildInputs =
      [
        go
        gopls
        goreleaser
      ]
      ++ (oa.nativeBuildInputs or []);
  })
