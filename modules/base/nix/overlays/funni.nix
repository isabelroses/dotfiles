_: prev: {
  cocogitto = prev.cocogitto.overrideAttrs (original: {
    postInstall =
      (original.postInstall or "")
      + ''
        ln -s $out/bin/cog $out/bin/goc
      '';
  });
}
