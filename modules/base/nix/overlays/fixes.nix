_: prev: {
  # https://github.com/NixOS/nixpkgs/pull/371815
  matrix-synapse-unwrapped = prev.matrix-synapse-unwrapped.overrideAttrs (oa: {
    patches = [
      (prev.fetchpatch2 {
        url = "https://github.com/element-hq/synapse/commit/3eb92369ca14012a07da2fbf9250e66f66afb710.patch";
        sha256 = "sha256-VDn3kQy23+QC2WKhWfe0FrUOnLuI1YwH5GxdTTVWt+A=";
      })
    ];

    postPatch =
      oa.postPatch or ""
      + ''
        substituteInPlace tests/storage/databases/main/test_events_worker.py \
          --replace-fail "def test_recovery" "def no_test_recovery"
      '';

    nativeCheckInputs = builtins.filter (p: !p.meta.broken) oa.nativeCheckInputs;
  });
}
