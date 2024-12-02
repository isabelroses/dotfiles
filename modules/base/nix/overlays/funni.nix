_: prev: {
  cocogitto = prev.cocogitto.overrideAttrs (original: {
    postInstall =
      (original.postPatch or "")
      + ''
        ln -s $out/bin/cog $out/bin/goc
      '';
  });
}
