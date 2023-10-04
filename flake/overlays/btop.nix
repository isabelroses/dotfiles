_: prev: {
  btop =
    if prev.stdenv.isLinux
    then
      prev.symlinkJoin {
        inherit (prev.btop) passthru;
        name = "btop-nodesktop";
        paths = [prev.btop];
        postBuild = ''
          rm $out/share/applications/btop.desktop
        '';
      }
    else prev.btop;
}
