{ self, config, ... }:
{
  nixpkgs.overlays = [
    # this file exists to work around issues with nixpkgs that may arise
    # hopefully that means its empty a lot
    (final: prev: import ./fixes.nix final prev)

    # this is how we pull in the patches applied to lix, we do it this way such that we can
    # build lix with ci, which is useful
    self.overlays.default
    (_: prev: import ./nix.nix { inherit config prev; })

    # remove desktop files from apps because i find them annoying
    (final: prev: import ./no-desktop.nix final prev)
  ];
}
