{
  eza,
  callPackage,
}:
let
  mainPkg = callPackage ./default.nix { };
in
mainPkg.overrideAttrs (oa: {
  nativeBuildInputs = [ eza ] ++ (oa.nativeBuildInputs or [ ]);
})
