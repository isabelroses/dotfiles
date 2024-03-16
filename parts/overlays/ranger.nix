_: prev: {
  ranger =
    if prev.stdenv.isLinux
    then
      prev.symlinkJoin {
        inherit (prev.ranger) passthru;
        name = "ranger-nodesktop";
        paths = [prev.ranger];
        postBuild = ''
          rm $out/share/applications/ranger.desktop
        '';
      }
    else prev.ranger;
}
