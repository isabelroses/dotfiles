{
  self,
  inputs,
  config,
  ...
}:
{
  nixpkgs.overlays = [
    # i want to use my own overlays
    # this is also how we pull in the patches applied to lix,
    # we do it this way such that we can build lix with ci, which is useful
    self.overlays.default

    # this file exists to work around issues with nixpkgs that may arise
    # hopefully that means its empty a lot
    (final: prev: import ./fixes.nix { inherit final prev inputs; })

    # we minimize the amount of packages that are installed
    (_: prev: import ./nix.nix { inherit config prev; })

    # remove desktop files from apps because i find them annoying
    (final: prev: import ./no-desktop.nix final prev)

    (final: prev: import ./funni.nix final prev)
  ];
}
