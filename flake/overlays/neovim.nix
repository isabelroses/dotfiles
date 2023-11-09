_: prev: {
  neovim =
    if prev.stdenv.isLinux
    then
      prev.symlinkJoin {
        inherit (prev.neovim-unwrapped) passthru;
        name = "neovim-nodesktop";
        paths = [prev.neovim-unwrapped];
        postBuild = ''
          rm $out/share/applications/*.desktop
        '';
      }
    else prev.neovim;
}
