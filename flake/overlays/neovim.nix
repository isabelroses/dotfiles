_: prev: {
  neovim =
    if prev.stdenv.isLinux
    then
      prev.symlinkJoin {
        inherit (prev.neovim) passthru;
        name = "neovim-nodesktop";
        paths = [prev.neovim];
        postBuild = ''
          rm $out/share/applications/*.desktop
        '';
      }
    else prev.neovim;
}
