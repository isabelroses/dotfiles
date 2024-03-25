{
  libcxx,
  gnumake,
  cppcheck,
  clang-tools,
  callPackage,
}: let
  mainPkg = callPackage ./default.nix {};
in
  mainPkg.overrideAttrs (oa: {
    nativeBuildInputs =
      [
        libcxx # stdlib for cpp
        gnumake # builder
        cppcheck # static analysis
        clang-tools # fix headers not found
      ]
      ++ (oa.nativeBuildInputs or []);
  })
