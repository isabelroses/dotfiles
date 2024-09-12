_: prev: {
  # FIXME: https://github.com/NixOS/nixpkgs/pull/341232
  subversionClient = prev.subversionClient.overrideAttrs (_: {
    env = prev.lib.optionalAttrs prev.stdenv.cc.isClang {
      NIX_CFLAGS_COMPILE = toString [
        "-Wno-error=implicit-function-declaration"
        "-Wno-error=implicit-int"
        "-Wno-int-conversion"
      ];
    };
  });
}
