{ lib, config, ... }:
let
  inherit (lib.lists) map;

  overlays = map import [
    ./fixes.nix
    ./funni.nix
    ./no-desktop.nix
  ];
in
{
  nixpkgs.overlays = overlays ++ [
    (final: prev: {
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

      # match our nixos-rebuild for all systems that install it
      nixos-rebuild = final.nixos-rebuild-ng;
      nixos-rebuild-ng = prev.nixos-rebuild-ng.override {
        nix = config.nix.package;
        withNgSuffix = false;
        withReexec = true;
      };
    })
  ];
}
