# I would highly advise you do not use my flake as an input and instead you vendor this
# if you want to use this code, you may want to add my cachix cache to your flake
# you may want to not have to build this for yourself however
{ inputs, ... }:
{
  perSystem =
    { pkgs, inputs', ... }:
    let
      inherit (pkgs) callPackage;
    in
    {
      packages = {
        inherit (callPackage ./pkgs/scripts/package.nix { })
          preview
          icat
          extract
          scripts
          ;

        lix = callPackage ./pkgs/lix/package.nix { inherit inputs' inputs; };
        docs = callPackage ./pkgs/docs.nix { inherit (inputs) self; };
      };
    };
}
