_: prev: {
  cocogitto = prev.symlinkJoin {
    name = "goc";
    paths = [ prev.cocogitto ];
    inherit (prev.cocogitto) passthru;
    postBuild = ''
      ln -s $out/bin/cog $out/bin/goc
    '';
  };
}
