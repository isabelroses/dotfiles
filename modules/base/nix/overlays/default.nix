{ lib, config, ... }:
let
  inherit (lib.lists) map;

  overlay =
    file: final: prev:
    import file final prev;

  overlays = map overlay [
    ./fixes.nix
    ./funni.nix
    ./no-desktop.nix
  ];
in
{
  nixpkgs.overlays = overlays ++ [
    (_: prev: {
      # in order to reduce our closure size, we can override these packages to
      # use the nix package that we have installed, this will trigget a rebuild
      # of the packages that depend on them so hopefully its worth it for that
      # system space
      nixVersions.stable = config.nix.package;

      # make sure to restore nix for linking back to nix from nixpkgs as its
      # used for other things then the cli implementaion
      nixForLinking = prev.nixVersions.stable;
    })
  ];
}
