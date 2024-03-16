{
  go,
  gopls,
  callPackage,
}: let
  mainPkg = callPackage ./default.nix {};
in
  mainPkg.overrideAttrs (oa: {
    nativeBuildInputs =
      [
        go
        gopls
      ]
      ++ (oa.nativeBuildInputs or []);
  })
