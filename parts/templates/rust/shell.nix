{
  clippy,
  rustfmt,
  callPackage,
  rust-analyzer,
}: let
  mainPkg = callPackage ./default.nix {};
in
  mainPkg.overrideAttrs (oa: {
    nativeBuildInputs =
      [
        # Additional rust tooling
        clippy
        rustfmt
        rust-analyzer
      ]
      ++ (oa.nativeBuildInputs or []);
  })
