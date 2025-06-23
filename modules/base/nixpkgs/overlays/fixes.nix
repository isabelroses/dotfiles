# this file exists to work around issues with nixpkgs that may arise
# hopefully that means its empty a lot
_: prev: {
  matrix-synapse-unwrapped = prev.matrix-synapse-unwrapped.overrideAttrs (oa: {
    version = "1.132.0";

    src = prev.fetchFromGitHub {
      owner = "element-hq";
      repo = "synapse";
      rev = "v1.132.0";
      hash = "sha256-yKoBYwd2djHAawBJRcbdrJH16+MHpYQnU7h39SvWqYE=";
    };

    patches = [
      # Skip broken HTML preview test case with libxml >= 2.14
      # https://github.com/element-hq/synapse/pull/18413
      (prev.fetchpatch {
        url = "https://github.com/element-hq/synapse/commit/8aad32965888476b4660bf8228d2d2aa9ccc848b.patch";
        hash = "sha256-EUEbF442nOAybMI8EL6Ee0ib3JqSlQQ04f5Az3quKko=";
      })
    ];
  });

  python313 = prev.python313.override {
    packageOverrides = pyfinal: pyprev: {
      tpm2-pytss = pyprev.tpm2-pytss.overrideAttrs (oa: {
        patches = oa.patches or [ ] ++ [
          # support cryptography >= 45.0.0
          # https://github.com/tpm2-software/tpm2-pytss/pull/643
          (prev.fetchpatch {
            url = "https://github.com/tpm2-software/tpm2-pytss/commit/6ab4c74e6fb3da7cd38e97c1f8e92532312f8439.patch";
            hash = "sha256-01Qe4qpD2IINc5Z120iVdPitiLBwdr8KNBjLFnGgE7E=";
          })
        ];
      });
    };
  };
}
