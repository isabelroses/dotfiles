{
  callPackage,
  gopls,
  go,
}: let
  mainPkg = callPackage ./default.nix {};
in
  mainPkg.overrideAttrs (oa: {
    nativeBuildInputs =
      [
        gopls
        go
      ]
      ++ (oa.nativeBuildInputs or []);
  })
