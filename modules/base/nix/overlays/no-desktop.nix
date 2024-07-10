# this file is a set of patches to remove the desktop files from this list of packages
# I do this because I don't want these packages to show up in my application launcher
#
# Also do note that we are using the symlinkJoin function to create a new derivation
# this is so we don't have to build the original packages again
{
  nixpkgs.overlays = [
    (_: prev: {
      btop =
        if prev.stdenv.isLinux then
          prev.symlinkJoin {
            inherit (prev.btop) passthru;
            name = "btop-nodesktop";
            paths = [ prev.btop ];
            postBuild = ''
              rm $out/share/applications/btop.desktop
            '';
          }
        else
          prev.btop;

      fish =
        if prev.stdenv.isLinux then
          prev.symlinkJoin {
            inherit (prev.fish) passthru meta;
            name = "fish-nodesktop";
            paths = [ prev.fish ];
            postBuild = ''
              rm $out/share/applications/fish.desktop
            '';
          }
        else
          prev.fish;

      ranger =
        if prev.stdenv.isLinux then
          prev.symlinkJoin {
            inherit (prev.ranger) passthru;
            name = "ranger-nodesktop";
            paths = [ prev.ranger ];
            postBuild = ''
              rm $out/share/applications/ranger.desktop
            '';
          }
        else
          prev.ranger;
    })
  ];
}
