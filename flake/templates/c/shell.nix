{
  callPackage,
  clang-tools,
  gnumake,
  libcxx,
  cppcheck,
}: let
  mainPkg = callPackage ./default.nix {};
in
  mainPkg.overrideAttrs (oa: {
    nativeBuildInputs =
      [
        clang-tools # fix headers not found
        gnumake # builder
        libcxx # stdlib for cpp
        cppcheck # static analysis
      ]
      ++ (oa.nativeBuildInputs or []);
  })
