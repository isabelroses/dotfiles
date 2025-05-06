# this file is a set of patches to remove the desktop files from this list of packages
# I do this because I don't want these packages to show up in my application launcher
#
# Also do note that we are using the symlinkJoin function to create a new derivation
# this is so we don't have to build the original packages again
_: prev: {
  btop =
    if prev.stdenv.hostPlatform.isLinux then
      prev.symlinkJoin {
        name = "btop-nodesktop";

        paths = [ prev.btop ];
        postBuild = ''
          rm $out/share/applications/btop.desktop
        '';

        inherit (prev.btop) version meta passthru;
      }
    else
      prev.btop;

  fish =
    if prev.stdenv.hostPlatform.isLinux then
      prev.symlinkJoin {
        name = "fish-nodesktop";

        paths = [ prev.fish ];
        postBuild = ''
          rm $out/share/applications/fish.desktop
        '';

        inherit (prev.fish) version passthru meta;
      }
    else
      prev.fish;

  ranger =
    if prev.stdenv.hostPlatform.isLinux then
      prev.symlinkJoin {
        name = "ranger-nodesktop";

        paths = [ prev.ranger ];
        postBuild = ''
          rm $out/share/applications/ranger.desktop
        '';

        inherit (prev.ranger) version passthru meta;
      }
    else
      prev.ranger;
}
