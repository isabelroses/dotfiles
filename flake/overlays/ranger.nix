_: prev: {
  btop =
    if prev.stdenv.isLinux
    then
      prev.symlinkJoin {
        inherit (prev.ranger) passthru;
        name = "btop-nodesktop";
        paths = [prev.ranger];
        postBuild = ''
          rm $out/share/applications/ranger.desktop
        '';
      }
    else prev.btop;
}
