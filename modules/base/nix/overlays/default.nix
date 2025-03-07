{
  config,
  ...
}:
{
  nixpkgs.overlays = [
    # this file exists to work around issues with nixpkgs that may arise
    # hopefully that means its empty a lot
    (final: prev: import ./fixes.nix final prev)

    # we minimize the amount of packages that are installed
    (_: prev: import ./nix.nix { inherit config prev; })

    # remove desktop files from apps because i find them annoying
    (final: prev: import ./no-desktop.nix final prev)

    (final: prev: import ./funni.nix final prev)
  ];
}
