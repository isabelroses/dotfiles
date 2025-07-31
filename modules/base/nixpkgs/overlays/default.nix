{ lib, config, ... }:
let
  inherit (lib) map;

  overlays = map import [
    # keep-sorted start
    ./fixes.nix
    ./funni.nix
    ./no-desktop.nix
    # keep-sorted end
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

      nil = (prev.nil.override { nix = config.nix.package; }).overrideAttrs (
        finalAttrs: oa: {
          src = prev.fetchFromGitHub {
            owner = "oxalica";
            repo = "nil";
            rev = "cd7a6f6d5dc58484e62a8e85677e06e47cf2bd4d";
            hash = "sha256-fK4INnIJQNAA8cyjcDRZSPleA+N/STI6I0oBDMZ2r+E=";
          };

          cargoDeps = prev.rustPlatform.fetchCargoVendor {
            inherit (finalAttrs) src;
            hash = "sha256-wvtCLCvpxbUo7VZPExUI7J+U06jnWBMnVuXqJeL/kOI=";
          };
        }
      );
    })
  ];
}
