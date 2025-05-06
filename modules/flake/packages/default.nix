# I would highly advise you do not use my flake as an input and instead you vendor this
# if you want to use this code, you may want to add my cachix cache to your flake
# you may want to not have to build this for yourself however
{ inputs, ... }:
{
  # get a list of packages for the host system, and if none exist use an empty set
  flake.overlays.default = _: prev: import ./pkgs { pkgs = prev; };

  perSystem =
    {
      pkgs,
      self',
      inputs',
      ...
    }:
    let
      inherit (pkgs) callPackage;
    in
    {
      packages = {
        lix = callPackage ./lix/package.nix { inherit inputs' inputs; };
        docs = callPackage ./docs/package.nix {
          inherit (inputs) self;
          inherit (self'.packages) libdoc;
        };
        libdoc = callPackage ./docs/lib.nix { inherit (inputs) self; };
        iztaller = callPackage ./iztaller/package.nix { nix = self'.packages.lix; };
      };
    };
}
