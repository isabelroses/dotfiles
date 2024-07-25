# this file creates an overlay based on the packgaes that out flake provides
{ lib, self, ... }:
{
  flake.overlays.default =
    _: prev:
    let
      # get a list of packages for the host system, and if none exist use an empty set
      # this is so we don't fail later, since builtins.attrNames will know that we are
      # an empty set is a empty list and won't generate an any attrs later
      myPkgs = self.packages.${prev.stdenv.hostPlatform.system} or { };
      myPkgsNames = builtins.attrNames myPkgs;
    in
    lib.attrsets.genAttrs myPkgsNames (name: myPkgs.${name});
}
