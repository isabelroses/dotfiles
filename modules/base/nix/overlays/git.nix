_: prev: {
  gitCustom = prev.git.override {
    withManual = false;
    osxkeychainSupport = prev.stdenv.hostPlatform.isDarwin;
    pythonSupport = false;
    perlSupport = false;
    withpcre2 = false;
  };
}
