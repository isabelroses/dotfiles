{ lib, config, ... }:
let
  inherit (lib) map;

  overlays = map import [
    ./fixes.nix
    ./funni.nix
    ./no-desktop.nix
  ];
in
{
  nixpkgs.overlays = overlays ++ [
    (_: prev: {
      # in order to reduce our closure size, we can override these packages to
      # use the nix package that we have installed, this will trigger a rebuild
      # of the packages that depend on them so hopefully its worth it for that
      # system space
      nixVersions = prev.nixVersions // {
        stable = config.nix.package;
      };

      # make sure to restore nix for linking back to nix from nixpkgs as its
      # used for other things then the cli implementation
      nixForLinking = prev.nixVersions.stable;
    })
  ];
}
