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
            rev = "b043bfe1f3f4c4be4b688e24c5ae96e81f525805";
            hash = "sha256-zXag1+8iZC3H5yVFP7KhIi4ps9z8xKrFIkyaeXlZ7Uo=";
          };

          cargoDeps = prev.rustPlatform.fetchCargoVendor {
            inherit (finalAttrs) src;
            hash = "sha256-Sljr3ff8hl/qm/0wqc1GXsEr1wWn7NAXmdrd5wHzUX8=";
          };
        }
      );
    })
  ];
}
